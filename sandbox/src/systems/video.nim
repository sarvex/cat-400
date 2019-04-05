import logging
import strformat

import c4/config
import c4/core/entities
import c4/systems
import c4/systems/network/enet
import c4/systems/video/ogre as ogre_video
import c4/lib/ogre/ogre
import c4/presets/action/systems/video
import c4/presets/action/messages
import c4/utils/stringify


type
  SandboxVideoSystem* = object of ActionVideoSystem

  SandboxVideo* = object of Video


# ---- Component ----
method init*(self: ref SandboxVideo) =
  assert config.systems.video of ref SandboxVideoSystem


# ---- System ----
strMethod(SandboxVideoSystem, fields=false)

method init*(self: ref SandboxVideoSystem) =
  procCall self.as(ref VideoSystem).init()
  logging.debug "Loading custom video resources"

  # ---- Setting up the scene ----
  var entity = self.sceneManager.createEntity("ogrehead.mesh")
  var node = self.sceneManager.getRootSceneNode().createChildSceneNode()
  node.attachObject(entity)

  self.sceneManager.setAmbientLight(initColourValue(0.5, 0.5, 0.5))

  var light = self.sceneManager.createLight("MainLight");
  light.setPosition(20.0, 80.0, 50.0);

method process*(self: ref SandboxVideoSystem, message: ref ConnectionOpenedMessage) =
  ## Load skybox when connection is established
  logging.debug "Loading skybox"


method process*(self: ref SandboxVideoSystem, message: ref ConnectionClosedMessage) =
  ## Unload everything when connection is closed
  logging.debug "Unloading skybox"

  # self.skybox.removeNode()
