return {
  {type = "settings", name = "main", datafile = "modules/mario/settings.lua"},
  {
    type = "ecs",
    name = "main",
    data = {
      entities = {code = "modules.mario.entities"},
      components = {},
      systems = {
        "systems.timer",
        "modules.mario.keyboardjoysticksystem",
        "systems.selfdestruct",
        "systems.physics",
        "systems.sound",
        "systems.touchbutton",
        "modules.mario.mariosystem",
        "systems.follower",
        "modules.mario.mariomapsystem",
        "modules.mario.brickbreakersystem",
        "modules.mario.devsystem",
      },
      drawSystems = {
        ["systems.viewportdraw"] = {
          "modules.mario.drawsystem",
          "systems.physicsdraw",
          "systems.debugdraw",
          "modules.mario.drawsound",
        },
      },
    },
  },
  {
    type = "picStrip",
    name = "smallstuff",
    data = {
      path = "data/images/mario/8x8stuff.png",
      picWidth = 8,
      picHeight = 8,
      count = 4,
      picOptions = {}, -- see ResourceLoader.makePic() for opts
      pics = {
        brickfrag_ul = 1,
        brickfrag_ur = 2,
        brickfrag_ll = 3,
        brickfrag_lr = 4,
      },
    },
  },
  {
    type = "picStrip",
    name = "mario",
    data = {
      path = "data/images/mario/mario.png",
      picWidth = 24,
      picHeight = 32,
      count = 10,
      picOptions = {}, -- see ResourceLoader.makePic() for opts
      anims = {
        mario_big_stand_left = {pics = {1}},
        mario_big_stand_right = {pics = {1}, sx = -1},
        mario_big_walk_left = {pics = {2, 3, 1}, frameDuration = 0.12},
        mario_big_walk_right = {pics = {2, 3, 1}, sx = -1, frameDuration = 0.12},
        mario_big_run_left = {pics = {2, 3, 1}, frameDuration = 0.06},
        mario_big_run_right = {pics = {2, 3, 1}, sx = -1, frameDuration = 0.06},
        mario_big_jump_left = {pics = {4}},
        mario_big_jump_right = {pics = {4}, sx = -1},
        mario_big_fall_left = {pics = {2}},
        mario_big_fall_right = {pics = {2}, sx = -1},
        mario_big_skid_left = {pics = {6}},
        mario_big_skid_right = {pics = {6}, sx = -1},
      },
    },
  },
  {
    type = "picStrip",
    name = "mapObjects",
    data = {
      path = "data/images/mario/map_objects.png",
      picWidth = 16,
      picHeight = 16,
      count = 10,
      picOptions = {}, -- see ResourceLoader.makePic() for opts
      anims = {
        brick_standard_matte = {pics = {9}},
        brick_standard_shimmer = {
          pics = {9, 6, 7, 8},
          frameDurations = {2, 0.1},
        },
        qblock_standard = {pics = {5, 1, 2, 3, 4}, frameDurations = {2, 0.1}},
      },
    },
  },
  {
    type = "sound",
    name = "bgmusic",
    data = {file = "data/mario/sounds/smb3_overworld_music.mp3", type = "music"},
  },
  {
    type = "sound",
    name = "jump",
    data = {file = "data/mario/sounds/smb_jump-super.wav", type = "sound"},
  },
  {
    type = "sound",
    name = "breakblock",
    data = {file = "data/mario/sounds/smb_breakblock.wav", type = "sound"},
  },
}
