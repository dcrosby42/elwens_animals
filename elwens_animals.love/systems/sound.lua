local Debug = require('mydebug').sub("Sound",true,true,true)

-- Accumulate's playtime for "playing" sounds.
-- For non-looping sounds, once playtime exceeds the duration property, the sound component is deleted.
return defineUpdateSystem({'sound'},
  function(e,estore,input,res)
    for _,sound in pairs(e.sounds) do
      if sound.state == 'playing' then
        -- accumulate time for playing sounds
        sound.playtime = sound.playtime + input.dt
        -- check for sound being done:
        if (not sound.loop) and (sound.duration ~= '') and (sound.playtime > sound.duration) then
          e:removeComp(sound)
          Debug.println(sound.sound .. " completed. playtime=" .. sound.playtime)
        end
      end
    end
  end
)
