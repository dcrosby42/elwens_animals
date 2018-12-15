local R = require 'resourceloader'
local Phys = require 'modules.fishbowl.resources_physics'
local AnimalRes = require 'modules.animalscreen.resources'
local Anim = require 'anim'

-- local debugPrint = print
local debugPrint = function() end

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
  pics["bubble_white"] = R.makePic("data/images/bubble_white.png")

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

local FishFPS=10
local FishW = 164.25
local FishH = 108

local function makeFishAnim(fname)
  local pics = Anim.simpleSheetToPics(R.getImage(fname), FishW,FishH)
  debugPrint("makeFishAnim fname="..fname)
  for i,pic in ipairs(pics) do
    debugPrint("  pic "..i.." rect="..tflatten(pic.rect))
  end

  return Anim.makeSimpleAnim(pics, 1/FishFPS)
end

local FishColors = {"black","blue","green","purple","yellow","red"}
local function loadFishAnims()
  local anims = {}
  for _,color in ipairs(FishColors) do
    for _,state in ipairs({"swim","idle"}) do
      anims["fish_"..color.."_"..state] = makeFishAnim("data/images/cartoon_fish_06_"..color.."_"..state..".png")
    end
  end
  return anims
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

    r.anims = loadFishAnims()
    r.fishColors = FishColors

    cached = r
  end
  return cached
end

return Res
