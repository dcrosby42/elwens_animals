local R = require 'resourceloader'
local AnimalRes = require 'modules.animalscreen.resources'
local Anim = require 'anim'

local Debug = require 'mydebug'
Debug = Debug.sub("Snowman res",true,true)


local Res = {}

local gifts = {
  red={
    name="gift_red",
    w=245,
    h=200,
    scale=0.25,
  },
  green={
    name="gift_green",
    w=245,
    h=200,
    scale=0.25,
  },
  gold={
    name="gift_gold",
    w=245,
    h=200,
    scale=0.25,
  },
  purple={
    name="gift_purple",
    w=200,
    h=180,
    scale=0.3,
    centerx=0.6,
    centery=0.4,
  },
}

local function loadPics()
  local pics = {}
  pics["woodsbg"] = R.makePic("data/images/woods.png")

  local pngs={
    "snowman_ball_1",
    "carrot",
    "coal1",
    "coal2",
    "coal3",
    "hat",
  }
  for _,name in ipairs(pngs) do
    pics[name] = R.makePic("data/images/"..name..".png")
  end

  for _,gift in pairs(gifts) do
    pics[gift.name] = R.makePic("data/images/"..gift.name..".png")
  end

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

  sounds["bgmusic"] = {
    file="data/sounds/music/Into-Battle_v001.mp3",
    mode="stream",
    volume=0.6,
  }
  sounds["woosh1"] = {
    file="data/sounds/fx/woosh.wav",
    mode="static",
    volume=1,
  }
  sounds["woosh2"] = {
    file="data/sounds/fx/woosh2.wav",
    mode="static",
    volume=1,
  }
  sounds["thud"] = {
    file="data/sounds/fx/thud.wav",
    mode="static",
    volume=1,
  }
  sounds["wpunch"] = {
    file="data/sounds/fx/woosh-punch.wav",
    mode="static",
    volume=1,
  }

  fetchSoundDatas(sounds)
  return sounds
end

local cached
function Res.load()
  if not cached then
    local r = {}

    r.pics = loadPics()
    tmerge(r.pics, AnimalRes.loadButtonPics())

    r.anims = loadAnims()

    r.sounds = loadSounds()

    r.gifts = gifts
    r.giftNames = {}
    for n,_ in pairs(gifts) do
      table.insert(r.giftNames, n)
    end

    cached = r
  end
  return cached
end

return Res
