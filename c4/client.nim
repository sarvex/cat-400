from logging import nil
from utils.loop import runLoop
from utils.helpers import importOrFallback
import conf

importOrFallback "systems/network"
importOrFallback "systems/video"
importOrFallback "systems/input"


proc run*(config: Config) =
  logging.debug("Starting client")

  network.init()
  network.connect((host: "localhost", port: config.network.port))

  video.init(
    title=config.title,
    windowConfig=config.video.window,
  )

  input.init(eventCallback=config.input.eventCallback)

  runLoop(
    updatesPerSecond = 30,
    fixedFrequencyCallback = proc(dt: float): bool {.closure.} = video.update(dt); return true,
    maxFrequencyCallback = proc(dt: float): bool {.closure.} = input.update(); network.poll(); return true,
  )

  logging.debug("Client shutdown")
  input.release()
  video.release()
