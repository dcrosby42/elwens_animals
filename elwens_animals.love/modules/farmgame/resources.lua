local R = require 'resourceloader'

local Res = {}

Res.animalNames = {
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

local function loadAnimalImages(images)
  images["background1"] = R.getImage("data/images/zoo_keeper.png")
  for _, name in ipairs(Res.animalNames) do
    images[name] = R.getImage("data/images/" .. name .. ".png")
  end
end

local function loadAnimalPics()
  local pics = {}
  for _, name in ipairs(Res.animalNames) do
    pics[name] = R.makePic("data/images/" .. name .. ".png")
  end
  return pics
end

local function loadGeneralPics()
  local names = {
    "wood_box",
    "wood_box_75",
    "lettuce_100",
    "strawberry_100",
    "apple_100",
    "bananas_100",
  }
  local pics = {}
  for _, imgName in ipairs(names) do
    pics[imgName] = R.makePic("data/images/" .. imgName .. ".png")
  end
  pics.background1 = R.makePic("data/images/zoo_keeper.png")
  return pics
end

function Res.loadSounds()
  local sounds = {}
  for _, name in ipairs(animalsWithSounds) do
    sounds[name] = {
      file = "data/sounds/fx/" .. name .. ".wav",
      mode = "static",
      volume = 0.5,
    }
  end
  sounds["bgmusic"] = {
    file = "data/sounds/music/music.wav",
    mode = "stream",
    volume = 0.5,
  }
  for name, cfg in pairs(sounds) do
    if not cfg.data then
      cfg.data = love.sound.newSoundData(cfg.file)
    end
    if not cfg.duration or cfg.duration == '' then
      cfg.duration = cfg.data:getDuration()
      print("resources: "..name.." sound computed duration "..cfg.duration)
    end
  end
  return sounds
end

local cached
function Res.load()
  if not cached then
    local r = {}
    r.animalNames = Res.animalNames

    r.pics = {}
    tmerge(r.pics, loadAnimalPics())
    tmerge(r.pics, Res.loadButtonPics())
    tmerge(r.pics, loadGeneralPics())

    r.sounds = Res.loadSounds()

    cached = r
  end
  return cached
end

function Res.loadButtonPics()
  local pics = {}
  pics["power-button-outline"] = R.makePic("data/images/power-button-outline.png")
  pics["skip-button-outline"] = R.makePic("data/images/skip-button-outline.png")
  return pics
end

return Res
