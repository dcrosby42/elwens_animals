local R = require 'resourceloader'
local Phys = require 'modules.fishbowl.resources_physics'
local AnimalRes = require 'modules.animalscreen.resources'

local Res = {}

local animalNames = {
  "fish",
  -- "penguin",
  "turtle",
}

local animalsWithSounds = {
  -- "fish",
}

local function loadAnimalPics()
  local pics = {}
  pics["aquarium"] = R.makePic("data/images/aquarium.jpg")
  pics["aquarium"] = R.makePic("data/images/aquarium.jpg")

  for _,name in ipairs(animalNames) do
    pics[name] = R.makePic("data/images/"..name..".png")
  end
  return pics
end

local function loadAnimalSounds()
  local sounds = {}
  for _,name in ipairs(animalsWithSounds) do
    sounds[name] ={
      file="data/sounds/fx/"..name..".wav",
      mode="static",
      volume=0.5,
    }
  end

  sounds["underwater"] = {
    file="data/sounds/fx/underwater.mp3",
    mode="static",
  }

  sounds["fishmusic"] = {
    file="data/sounds/music/Chamber-of-Jewels.mp3",
    mode="stream",
    volume=0.1,
  }

  for name,cfg in pairs(sounds) do
    if not cfg.data then
      cfg.data = love.sound.newSoundData(cfg.file)
    end
    if not cfg.duration or cfg.duration == '' then
      cfg.duration = cfg.data:getDuration()
    end
  end
  return sounds
end

local cached
function Res.load()
  if not cached then
    local r = {}
    r.animalNames = animalNames

    r.pics = loadAnimalPics()
    tmerge(r.pics, AnimalRes.loadButtonPics())

    r.sounds = loadAnimalSounds()
    r.physics = {
      newObject=Phys.newObject,   -- func(w, e) -> {body,shapes,fixtures,componentId}
      caches={},                  -- map cid -> {world,objectCache,collisionBuffer}
    }
    cached = r
  end
  return cached
end

return Res
