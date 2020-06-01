return {
  {
    type = "settings",
    name = "mydebug",
    data = {
      Joystick = {onConsole = true},
      JoystickConfig = {onConsole = true},
      JoystickTracker = {onConsole = true},
      resourceloader = {onConsole = false},
    },
  },
  -- {
  --   type = "data",
  --   name = "snes_layout",
  --   datafile = "modules/joystickconfig/maps/snes_layout.lua",
  -- },
  {
    type = "data",
    name = "joystickViews",
    expandDatafiles = true,
    data = {
      Dualshock = {
        datafile = "modules/joystickconfig/maps/generic_dualstick_layout.lua",
      },
      GamePadPro = {
        datafile = "modules/joystickconfig/maps/gamepad_pro_layout.lua",
      },
      Snes = {datafile = "modules/joystickconfig/maps/snes_layout.lua"},
    },
  },
}
