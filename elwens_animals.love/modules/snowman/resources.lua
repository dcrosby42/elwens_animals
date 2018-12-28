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
  pics["snowman_ball_1"] = R.makePic("data/images/snowman_ball_1.png")

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

  -- TODO
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
