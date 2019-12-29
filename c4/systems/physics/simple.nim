import tables
import logging
import strformat
import os
when isMainModule:
  import unittest

import ../../entities
import ../../messages
import ../../loop
import ../../threads


type
  SimplePhysicsSystem* {.inheritable.} = object

  Vector* = tuple[x: float, y: float]

  SimplePhysics* {.inheritable.} = object
    position*: Vector
    width*, height*: float
    speed*: Vector  # defines direction & speed


proc `+`*(v1: Vector, v2: Vector): Vector =
  result.x = v1.x + v2.x
  result.y = v1.y + v2.y


method init*(self: ref SimplePhysicsSystem) {.base.} =
  discard

proc handleCollision*(entity1: Entity, entity2: Entity, jointPoint: Vector) =
  discard

method update*(self: ref SimplePhysicsSystem, dt: float) {.base.} =
  # calculate new position for every Physics instance
  for physics in getComponents(ref SimplePhysics).mvalues():
    physics.position = physics.position + physics.speed

  # find collisions
  discard

method dispose*(self: ref SimplePhysicsSystem) {.base.} =
  discard

method process*(self: ref SimplePhysicsSystem, message: ref Message) {.base.} =
  logging.warn &"Don't know how to process {message}"

method run*(self: ref SimplePhysicsSystem) {.base.} =
  loop(frequency=30) do:
    self.update(dt)
    while true:
      let message = tryRecv()
      if message.isNil:
        break
      self.process(message)


when isMainModule:
  suite "System tests":
    test "Running inside thread":
      spawn("thread") do:
        let system = new(SimplePhysicsSystem)
        system.init()
        system.run()
        system.dispose()

      sleep 1000
