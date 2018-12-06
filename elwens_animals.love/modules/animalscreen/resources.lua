local R = require 'resourceloader'
local Phys = require 'modules.animalscreen.resources_physics'

local Res = {}

local animalNames = {
  "bear",
  "bee",
  "bunny",
  "cat",
  "chicken",
  "cow",
  "dog",
  "elephant",
  "fish",
  "giraffe",
  "goat",
  "hippo",
  "horse",
  "kangaroo",
  "lemur",
  "leopard",
  "lion",
  "monkey",
  "mouse",
  "owl",
  "penguin",
  "pig",
  "sheep",
  "squirrel",
  "turtle",
  "zebra",
}

local animalsWithSounds = {
  "cat",
  "cow",
  "elepant",
  "elephant",
  "fish",
  "horse",
  "lion",
  "monkey",
  "pig",
}

local function loadAnimalImages()
  local images = {}
  images["background1"] = R.getImage("data/images/zoo_keeper.png")
  for _,name in ipairs(animalNames) do
    images[name] = R.getImage("data/images/"..name..".png")
  end
  return images
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
  sounds["bgmusic"] = {
    file="data/sounds/music/music.wav",
    mode="stream",
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

    r.images = loadAnimalImages()
    r.images["power-button-outline"] = R.getImage("data/images/power-button-outline.png")

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
