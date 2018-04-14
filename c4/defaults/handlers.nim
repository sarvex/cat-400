import logging

import "../core/messages"
import "../core/states"

import "../wrappers/enet/enet"
import "../wrappers/msgpack/msgpack"

import "../systems"
import "../systems/network"
import "../systems/video"
import "../wrappers/horde3d/horde3d"

import messages as default_messages
import states as default_states
import "../config"


method store*(self: ref NetworkSystem, message: ref QuitMessage) =
  # by default network system sends all local incoming messages
  # however, we want to store and process ConnectMessage
  procCall ((ref System)self).store(message)

method process*(self: ref NetworkSystem, message: ref QuitMessage) =
  self.disconnect()
  config.state.switch(new(FinalState))
