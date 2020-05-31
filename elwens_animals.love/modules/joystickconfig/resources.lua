return {
  {
    type = "settings",
    name = "mydebug",
    data = {
      Joystick = {onConsole = false},
      JoystickConfig = {onConsole = false},
    },
  },
  {
    type = "data",
    name = "gamepad_layout",
    datafile = "modules/joystickconfig/maps/gamepad_layout.lua",
  },
  {
    type = "data",
    name = "snes_layout",
    datafile = "modules/joystickconfig/maps/snes_layout.lua",
  },
  {
    type = "data",
    name = "gamepad_pro_layout",
    datafile = "modules/joystickconfig/maps/gamepad_pro_layout.lua",
  },
  {
    type = "data",
    name = "generic_dualstick_layout",
    datafile = "modules/joystickconfig/maps/generic_dualstick_layout.lua",
  },
  {
    type = "data",
    name = "joysticks",
    data = {
      ["Generic   USB  Joystick  "] = {
        axes = {leftx = 1, lefty = 2, unknown = 3, rightx = 4, righty = 5},
        buttons = {
          face1 = 1,
          face2 = 2,
          face3 = 3,
          face4 = 4,
          l2 = 5,
          r2 = 6,
          l1 = 7,
          r1 = 8,
          select = 9,
          start = 10,
          l3 = 11,
          r3 = 12,
        },
        viewLayout = "generic_dualstick_layout",
      },
      ["GamePad Pro USB "] = {
        axes = {leftx = 1, lefty = 2, unknown = 3, rightx = 4, righty = 5},
        buttons = {
          face1 = 1,
          face2 = 2,
          face3 = 3,
          face4 = 4,
          l2 = 5,
          r2 = 6,
          l1 = 7,
          r1 = 8,
          select = 9,
          start = 10,
          l3 = 11,
          r3 = 12,
        },
        viewLayout = "gamepad_pro_layout",
      },
    },
  },
}
