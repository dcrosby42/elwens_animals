local R = require 'resourceloader'
local AnimalRes = require 'modules.animalscreen.resources'
local Anim = require 'anim'

local Debug = require 'mydebug'
Debug = Debug.sub("Snowman res",true,true)


local Res = {}

local function loadPics()
  local pics = {}
  -- pics["woodsbg"] = R.makePic("data/images/woods.png")
  -- local pngs={
  --   "snowman_ball_1",
  --   "carrot",
  --   "coal1",
  --   "coal2",
  --   "coal3",
  --   "hat",
  -- }
  -- for _,name in ipairs(pngs) do
  --   pics[name] = R.makePic("data/images/"..name..".png")
  -- end

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

  -- sounds["bgmusic"] = {
  --   file="data/sounds/music/Into-Battle_v001.mp3",
  --   mode="stream",
  --   volume=0.6,
  -- }
  -- sounds["woosh1"] = {
  --   file="data/sounds/fx/woosh.wav",
  --   mode="static",
  --   volume=1,
  -- }

  fetchSoundDatas(sounds)
  return sounds
end

local cached
function Res.load()
  if not cached then
    local r = AnimalRes.load()

    tmerge(r.pics, loadPics())

    r.anims = r.anims or {}
    tmerge(r.anims, loadAnims())

    tconcat(r.sounds, loadSounds())

    cached = r
  end
  return cached
end

return Res
