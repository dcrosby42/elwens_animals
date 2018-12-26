local R = require 'resourceloader'
local Phys = require 'modules.snowman.resources_physics'
local AnimalRes = require 'modules.animalscreen.resources'
local Anim = require 'anim'

local Debug = require 'mydebug'
Debug = Debug.sub("Snowman res",true,true)


local Res = {}

local function loadPics()
  local pics = {}
  pics["woodsbg"] = R.makePic("data/images/woods.png")
  pics["snowman_ball_1"] = R.makePic("data/images/snowman_ball_1.png")

  return pics
end

local function loadAnims()
  local anims = {}
  return anims
end

local function fetchSoundDatas(sounds)
  for name,cfg in pairs(sounds) do
    if not cfg.data then
      cfg.data = R.getSoundData(cfg.file)
    end
    if not cfg.duration or cfg.duration == '' then
      cfg.duration = cfg.data:getDuration()
    end
  end
end

local function loadSounds()
  local sounds = {}

  -- FIXME
  -- sounds["bgmusic"] = {
  --   file="data/sounds/music/xmas_bg_music.mp3",
  --   mode="stream",
  --   volume=0.25,
  -- }

  fetchSoundDatas(sounds)
  return sounds
end

local cached
function Res.load()
  if not cached then
    local r = {}

    r.pics = loadPics()
    tmerge(r.pics, AnimalRes.loadButtonPics())

    r.ornamentNames = ornamentNames

    r.anims = loadAnims()

    r.sounds = loadSounds()

    r.physics = {
      newObject=Phys.newObject,   -- func(pw, e) -> {body,shapes,fixtures,componentId}
      newJoint=Phys.newJoint,   -- func(pw, jointComp, e, estore, objCache) -> {joint}
      caches={},                  -- map cid -> {world,objectCache,collisionBuffer}
    }


    cached = r
  end
  return cached
end

return Res
