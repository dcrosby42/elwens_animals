local R = require 'resourceloader'
local Anim = require 'anim'

local Res = {}

local PicPrefix = "data/images/sungirl"
-- local SoundPrefix = "data/sounds/sungirl"

local function makePic(res, name, path)
  if not path then
    path = PicPrefix .. "/" .. name .. ".png"
  end
  return R.makePic(path)
end

local function addPic(res, name, path)
  res.pics[name] = makePic(res, name, path)
end

local function addSketchWalkAnim(resources)
  -- 160x275  
  local pics = lmap({
    "sketch_walk_01",
    "sketch_walk_02",
    "sketch_walk_03",
    "sketch_walk_04",
  }, function(name) return makePic(resources,name) end)
  resources.anims["sketch_walk_right"] = Anim.makeSimpleAnim(pics, 1/5)
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

  addSketchWalkAnim(resources)

  return resources
end

return Res
