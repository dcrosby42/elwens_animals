local R = require "resourceloader"
local AnimalRes = require "modules.animalscreen.resources"
local Anim = require "anim"

local Debug = require "mydebug"
Debug = Debug.sub("Snowman res", true, true)

local Res = {}

local function loadPics()
  local pics = {}
  return pics
end

local MarioFrameW = 24
local MarioFrameH = 32
local ImgScale = 1
local function makeMarioAnims()
  local anims = {}
  local pics =
    Anim.simpleSheetToPics(
    R.getImage("data/images/mario/mario.png"),
    MarioFrameW,
    MarioFrameH,
    {sx = ImgScale, sy = ImgScale}
  )

  -- for i = 1, #pics do
  --   pics[i].sx = ImgScale
  --   pics[i].sy = ImgScale
  -- end

  -- standing
  anims.mario_big_stand_left = Anim.makeSinglePicAnim(pics[1])
  anims.mario_big_stand_right = Anim.makeSinglePicAnim(pics[1])
  anims.mario_big_stand_right.sx = -1
  -- walking
  local walkFrameDur = 0.12
  anims.mario_big_walk_left = Anim.makeSimpleAnim({pics[2], pics[3], pics[1]}, walkFrameDur)
  anims.mario_big_walk_right = Anim.makeSimpleAnim({pics[2], pics[3], pics[1]}, walkFrameDur)
  anims.mario_big_walk_right.sx = -1
  -- running
  local runFrameDur = 0.06
  anims.mario_big_run_left = Anim.makeSimpleAnim({pics[2], pics[3], pics[1]}, runFrameDur)
  anims.mario_big_run_right = Anim.makeSimpleAnim({pics[2], pics[3], pics[1]}, runFrameDur)
  anims.mario_big_run_right.sx = -1
  -- jumping
  anims.mario_big_jump_left = Anim.makeSinglePicAnim(pics[4])
  anims.mario_big_jump_right = Anim.makeSinglePicAnim(pics[4])
  anims.mario_big_jump_right.sx = -1
  -- falling
  anims.mario_big_fall_left = Anim.makeSinglePicAnim(pics[2])
  anims.mario_big_fall_right = Anim.makeSinglePicAnim(pics[2])
  anims.mario_big_fall_right.sx = -1
  -- skidding
  anims.mario_big_skid_left = Anim.makeSinglePicAnim(pics[6])
  anims.mario_big_skid_right = Anim.makeSinglePicAnim(pics[6])
  anims.mario_big_skid_right.sx = -1

  return anims
end

local function makeBrickAnims()
  local anims = {}
  local pics = Anim.simpleSheetToPics(R.getImage("data/images/mario/map_objects.png"), 16, 16, {sx = 1, sy = 1})

  anims.brick_standard_matte = Anim.makeSinglePicAnim(pics[9])

  local shimmerFrameDur = 0.1
  anims.brick_standard_shimmer = Anim.makeSimpleAnim({pics[9], pics[6], pics[7], pics[8]}, shimmerFrameDur)
  anims.brick_standard_shimmer.pics[1].duration = 2
  Anim.recalcDuration(anims.brick_standard_shimmer)

  local qblockDur = 0.1
  anims.qblock_standard = Anim.makeSimpleAnim({pics[5], pics[1], pics[2], pics[3], pics[4]}, qblockDur)
  anims.qblock_standard.pics[1].duration = 2
  Anim.recalcDuration(anims.qblock_standard)

  return anims
end

local function loadAnims()
  local anims = {}
  tmerge(anims, makeMarioAnims())
  tmerge(anims, makeBrickAnims())
  return anims
end

local function fetchSoundDatas(sounds)
  for name, cfg in pairs(sounds) do
    if not cfg.data then
      cfg.data = R.getSoundData(cfg.file)
    end
    if not cfg.duration or cfg.duration == "" then
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

local function doLoad()
  local r = AnimalRes.load()

  tmerge(r.pics, loadPics())

  r.anims = r.anims or {}
  tmerge(r.anims, loadAnims())

  tconcat(r.sounds, loadSounds())
  return r
end

-- local _loaded
-- function Res.load()
--   if not _loaded then
--     _loaded = doLoad()
--   end
--   return _loaded
-- end

Res.load =
  lazyThunk(
  function()
    return doLoad()
  end
)

return Res
