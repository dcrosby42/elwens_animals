local Debug = require("mydebug").sub("Sound", false, false)

-- Accumulate's playtime for "playing" sounds.
-- For non-looping sounds, once playtime exceeds the duration property, the sound component is deleted.
return defineUpdateSystem(
  {"sound"},
  function(e, estore, input, res)
    for _, sound in pairs(e.sounds) do
      if sound.state == "playing" then
        -- accumulate time for playing sounds
        sound.playtime = sound.playtime + input.dt
        if (not sound.duration or sound.duration == "") then
          -- (other systems may need this value, but component originators shouldn't need to dig up the resource info, so we help out here)
          Debug.println("backfilled duration for " .. tflatten(sound))
          sound.duration = res.sounds[sound.sound].duration
        end
        -- check for sound being done:
        if (not sound.loop) and (sound.playtime > sound.duration) then
          Debug.println("Sound over, removing " .. tflatten(sound))
          e:removeComp(sound)
        end
      end
    end
  end
)
