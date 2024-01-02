local R = require 'resourceloader'
local Anim = require 'anim'
local Debug = require('mydebug').sub("SunGirl.resources")

local Res = {}

local PicPrefix = "data/images/sungirl"
-- local SoundPrefix = "data/sounds/sungirl"

local function makePic(name, path)
  if not path then
    path = PicPrefix .. "/" .. name .. ".png"
  end
  return R.makePic(path)
end

local function addPic(res, name, path)
  res.pics[name] = makePic(name, path)
end

local function addSketchWalkAnim(resources)
  -- 160x275  
  local pics = lmap({
    "sketch_walk_01",
    "sketch_walk_02",
    "sketch_walk_03",
    "sketch_walk_04",
  }, function(name) return makePic(name) end)
  resources.anims["sketch_walk_right"] = Anim.makeSimpleAnim(pics, 1/5)
end

local function addSunGirlAnimations(resources)
  local rate = 1/8

  local runRight = lmap({
    "Sun_girl_animation-3",
    "Sun_girl_animation-4",
    "Sun_girl_animation-5",
    "Sun_girl_animation-6",
  }, function(name) return makePic(name) end)
  resources.anims["sungirl_run"] = Anim.makeSimpleAnim(runRight, rate)


  local standPics = {
    makePic("Sun_girl_animation-2"), -- eyes closed
    makePic("Sun_girl_animation-1"),
  }
  standPics[1].duration = 5
  standPics[2].duration = 0.2
  resources.anims["sungirl_stand"] = Anim.makeSimpleAnim(standPics)

end

-- cached resources object, populated after Res.load()
local resources

function Res.load()
  if resources then return resources end

  resources = {
    pics={},
    anims={},
    sounds={},
  }

  addPic(resources, "background01")
  addPic(resources, "Sungirl_items-1")
  addPic(resources, "Sungirl_items-2")
  addPic(resources, "Sungirl_sun-1")
  resources.pics["umbrella"] = resources.pics["Sungirl_items-1"]
  resources.pics["flower1"] = resources.pics["Sungirl_items-2"]
  resources.pics["big_sun"] = resources.pics["Sungirl_sun-1"]

  addSketchWalkAnim(resources)
  addSunGirlAnimations(resources)

  return resources
end

return Res
