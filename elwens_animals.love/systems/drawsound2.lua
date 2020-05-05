local SoundCanvas = require("crozeng.soundcanvas")
local sndCanvas = SoundCanvas.default
local inspect = require("inspect")

local Debug = require "mydebug"
Debug = Debug.sub("SoundManager", false, false)

local DrawSound = {}

-- https://www.youtube.com/watch?v=WT5nfQJP40Y

-- 'sound' comp: {loop=false, state='playing',volume=1,pitch=1,playtime=0,duration=''}
-- soundConfig: {  (from Resources)
--     file="data/sounds/music/Into-Battle_v001.mp3",
--     mode="stream",
--     source={love.audio.Source}
--     data=love.sound.newSoundData(file),
--     volume=0.6,
--     duration=0.2 -- either configured or calc'd
--   }
-- Source https://love2d.org/wiki/Source
--

function DrawSound.new(prefix)
  return defineDrawSystem(
    {"sound"},
    function(e, estore, res)
      -- For each sound component in this entity:
      for _, soundComp in pairs(e.sounds) do
        local key = prefix .. "." .. soundComp.sound .. "." .. soundComp.cid
        local soundConfig = res.sounds[soundComp.sound]
        local soundState = {
          playState = soundComp.state,
          volume = soundComp.volume,
          pitch = soundComp.pitch,
          playTime = soundComp.playtime,
          duration = soundComp.duration,
          isLooping = soundComp.loop
        }
        sndCanvas:drawSound(key, soundConfig, soundState)
      end -- end for-each sound component
    end -- end handler
  ) -- end system
end -- end "new"

return DrawSound
