import tables
import logging
import strformat
import typetraits

import "../../../systems"
import "../../../config"
import "../../../core/entities"
import "../../../core/messages"
import "../../../systems/physics/ode" as physics_system
import "../../../systems/network/enet"
import "../../../wrappers/ode/ode"
import "../../../utils/stringify"

import "../messages" as action_messages


type
  ActionPhysicsSystem* = object of PhysicsSystem
    peersEntities: Table[ref Peer, Entity]  ## Table for converting remote Peer to Entity which he has control over

  ActionPhysics* = object of Physics
    ## Physics component which additionally stores its previous position. Position update messages are sent only when position really changes.
    prevPosition: tuple[x, y, z: dReal]


const
  G* = 9.81


method init*(self: ref ActionPhysicsSystem) =
  ## Sets real world gravity (G) 
  procCall self.as(ref PhysicsSystem).init()
  
  self.peersEntities = initTable[ref Peer, Entity]()
  self.world.worldSetGravity(0, -G, 0)

method initComponent*(self: ref ActionPhysicsSystem, component: ref ActionPhysics) =
  ## This method remembers component's inital position
  procCall self.as(ref PhysicsSystem).initComponent(component)

  let position = component.getPosition()
  component.prevPosition = (position.x, position.y, position.z)

method update*(self: ref ActionPhysics, dt: float, entity: Entity) =
  ## This method compares previous position and rotation of entity, and (if there are any changes) sends ``MoveMessage`` or ``RotateMessage``.
  let position = self.getPosition()
  if (position.x != self.prevPosition.x) or (position.y != self.prevPosition.y) or (position.z != self.prevPosition.z):
    self.prevPosition = (position.x, position.y, position.z)
    (ref SetPositionMessage)(
      entity: entity,
      x: position.x,
      y: position.y,
      z: position.z,
    ).send(config.systems.network)

  # TODO: implement rotation
    #   pitch: 0.0,  
    #   yaw: 0.0,
    # ).send(config.systems.network)


method process*(self: ref ActionPhysicsSystem, message: ref ConnectionOpenedMessage) =
  ## When new peer connects, we want to create a corresponding Entity for him.
  ## We also need to send all world information to new peer.
  
  var physics = new(ActionPhysics)
  config.systems.physics.initComponent(physics)
  physics.body.bodySetPosition(0.0, 0.0, 0.0)

  var mass = ode.dMass()
  mass.addr.massSetBoxTotal(10.0, 1.0, 1.0, 1.0)
  physics.body.bodySetMass(mass.addr)

  let playerEntity = newEntity()  # create new Entity
  playerEntity[ref Physics] = physics
  
  self.peersEntities[message.peer] = playerEntity  # add it to mapping

  # send all scene data
  for entity, physics in getComponents(ref Physics).pairs():
    (ref CreateEntityMessage)(entity: entity, recipient: message.peer).send(config.systems.network)
    let position = physics.getPosition()
    (ref SetPositionMessage)(entity: entity, x: position.x, y: position.y, z: position.z, recipient: message.peer).send(config.systems.network)

    # TODO: send "rotate" message

  # # send "impersonate" message for playerEntity
  # (ref ImpersonateMessage)(entity: playerEntity).send(config.systems.network, receiver=message.peer)

method process*(self: ref ActionPhysicsSystem, message: ref ConnectionClosedMessage) =
  ## When peer disconnects, we want to remove a corresponding Entity.

  logging.debug &"Received {message} message, removing entity"
  self.peersEntities[message.peer].delete()  # delete Entity # TODO: physics not deleted!
  self.peersEntities.del(message.peer)  # exclude peer's Entity from mapping
