require "ecs.ecshelpers"
local EcsAdapter = require "ecs.moduleadapter"

local Debug = require("mydebug").sub("Mario", true, true)
local Resources = require "modules.mario.resources"
local Entities = require "modules.mario.entities"
local DrawStuff = require "systems.drawstuff"
local DrawSound = require "systems.drawsound"
local KeyboardJoystick = require "modules.mario.keyboardjoystick"

-- FIXME this is a non-great hackup to map wasd keys etc. to pretend to be "joystick1":
local kbd_mapping = {
  axes = {
    w = {"lefty", -1, "s"},
    s = {"lefty", 1, "w"},
    a = {"leftx", -1, "d"},
    d = {"leftx", 1, "a"}
  },
  buttons = {
    [","] = "face4",
    ["."] = "face3"
  }
}

local kbd_state = {
  controllerId = "joystick1"
}

local keyboardJoystickSystem = KeyboardJoystick.construct(kbd_mapping, kbd_state)

local UPDATE =
  composeSystems(
  {
    "systems.timer",
    keyboardJoystickSystem,
    "systems.selfdestruct",
    "systems.physics",
    "systems.sound",
    "systems.touchbutton",
    "modules.mario.mariosystem",
    -- 'modules.mario.playertrackersystem',
    -- "systems.viewport"
    "systems.follower",
    "modules.mario.mariomapsystem"
  }
)

-- Wrap the Viewport drawing system around all the others:
local DRAW =
  require("systems.viewportdraw").wrap(
  composeDrawSystems(
    {
      "modules.mario.drawsystem",
      "systems.physicsdraw",
      "systems.debugdraw"
      -- DrawSound.new("mario")
    }
  )
)

return EcsAdapter(
  {
    loadResources = Resources.load,
    create = Entities.initialEntities,
    update = UPDATE,
    draw = DRAW
  }
)
