
local soundmanager = require 'crozeng.soundmanager'

local Debug = require('mydebug').sub("DrawSound", true, true, true)

local function getSoundKey(sndComp)
  return "sound." ..sndComp.eid.. "." .. sndComp.cid .. "." .. sndComp.sound
end

local function drawSound(sndCmp, e, estore, res)
  local key = getSoundKey(sndCmp)

  -- Is there already a Source for this sound component?
  local audioSrc = soundmanager.get(key)
  if audioSrc then
    -- Source already existing.
    if sndCmp.state == "playing" and not audioSrc:isPlaying() then
      audioSrc:play()
    elseif sndCmp.state ~= "playing" and audioSrc:isPlaying() then
      audioSrc:pause()
    end
    -- (TODO Update audioSrc from sound component state)
    -- Poke the soundmanager to let 'im know we still care about this sound:
    soundmanager.manage(key, audioSrc)
  else
    if sndCmp.state == 'playing' then
      -- Sound component is new and playing.
      -- 1. Lookup our sound configuration in resources
      -- 2. Create and configure new love.audio Source object
      -- 3. Register the Source with soundmanager for ongoing maint
      Debug.println("Playing sound " .. sndCmp.sound)
      local soundCfg = res.sounds[sndCmp.sound]
      if soundCfg then
        -- New Source:
        local audioSrc = love.audio.newSource(soundCfg.data, soundCfg.mode or "static")

        -- Looping:
        audioSrc:setLooping(sndCmp.loop)

        -- Time offset:
        if sndCmp.duration == '' then
          print("Wtf? blank duration? " .. tflatten(sndCmp))
        else
          audioSrc:seek(sndCmp.playtime % sndCmp.duration)
        end

        -- Volume:
        local vol = sndCmp.volume
        if soundCfg.volume then
          vol = vol * soundCfg.volume
        end
        audioSrc:setVolume(vol)

        -- Manage:
        soundmanager.manage(key, audioSrc)

        -- Start playing:
        audioSrc:play()
      else
        Debug.println("!! update() unknown sound in " .. tflatten(sndCmp))
      end -- end if soundCfg
    else
      -- Debug.println("Not playing")
    end   -- end if playing
  end     -- end if src
end

return defineDrawSystem({ 'sound' }, function(e, estore, res)
  for _, snd in pairs(e.sounds) do
    drawSound(snd, e, estore, res)
  end
end)

