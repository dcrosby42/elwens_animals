local KeyboardJoystick = require "modules.mario.keyboardjoystick"

-- FIXME this is a non-great hackup to map wasd keys etc. to pretend to be "joystick1":
-- FIXME how great is it to just close over some state and modify all day long.
-- So much for stateless systems. >:( (croz being lazy)
return {
  new = function(_res)

    local mapping = {
      axes = {
        w = {"lefty", -1, "s"},
        s = {"lefty", 1, "w"},
        a = {"leftx", -1, "d"},
        d = {"leftx", 1, "a"},
      },
      buttons = {[","] = "face4", ["."] = "face3"},
    }

    local state = {controllerId = "joystick1"}

    return function(estore, input, res)
      KeyboardJoystick.generateEvents(input.events, mapping, state)
    end
  end,
}
