
local soundmanager = require 'crozeng.soundmanager'

local Debug=require 'mydebug'
Debug = Debug.sub("SoundManager", false,false)

local DrawSound = {}

function DrawSound.new(prefix)
  return defineDrawSystem({'sound'},
    function(e,estore,res)
      -- For each sound component in this entity:
      for _,snd in pairs(e.sounds) do
        local key = prefix.."."..snd.sound.."."..snd.cid
        -- Is the sound already known??
        local src = soundmanager.get(key)
        if src then
          -- Sound already known. 
          -- TODO Update src from sound component state

          soundmanager.manage(key,src) -- important to poke the soundmanager to let 'im know we still care about this sound
        else
          if snd.state == 'playing' then
            -- Sound component is new, we need to act.
            Debug.println("Playing sound "..snd.sound)
            local soundCfg = res.sounds[snd.sound]
            if soundCfg then
              local src = love.audio.newSource(soundCfg.data, soundCfg.mode or "static")
              src:setLooping(snd.loop)
              -- if snd.loop and snd.duration and snd.duration ~= '' then
              --   src:seek(snd.playtime % snd.duration)
              -- else
              if snd.duration == '' then
                print("Wtf? blank duration? "..tflatten(snd))
              else
                src:seek(snd.playtime % snd.duration)
              end
              -- end
              local vol = snd.volume
              if soundCfg.volume then
                vol = vol * soundCfg.volume
              end
              src:setVolume(vol)

              soundmanager.manage(key,src)
              src:play()
            else
              Debug.println("!! update() unknown sound in "..tflatten(snd))
            end -- end if soundCfg
          end -- end if playing
        end -- end if src
      end -- end for-each sound
    end -- end handler
  ) -- end system
end -- end "new"

return DrawSound
