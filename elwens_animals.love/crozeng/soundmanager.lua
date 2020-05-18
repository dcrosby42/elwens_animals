local Debug = require('mydebug').sub("soundmanager")
local GC = require('garbagecollect')

local soundmanager = {}

local Time = 0
local Regs = {}

local _paused = false
local _pausedSources = {}

function soundmanager.get(key)
  local reg = Regs[key]
  if reg then return reg.source end
  return nil
end

function soundmanager.manage(key,source)
  if _paused then return end
  -- Debug.println("Time="..math.round(Time,3).." manage("..key..")")
  local reg = Regs[key]
  if not reg then
    Debug.println("Time="..math.round(Time,3).." Start managing "..key)
    reg = {
      key=key,
      source=source,
      time=Time,
    }
    Regs[key] = reg
  else
    reg.source = source
    reg.time =Time 
  end
end

function soundmanager.update(dt)
  if _paused then return end
  for key,reg in pairs(Regs) do
    if Time > reg.time then
      -- This source registration has expired, meaning nobody has registered "recent" interest.
      -- Kick the sound out of the world
      Debug.println("Time="..math.round(Time,3).." stopping and kicking "..key..", last seen "..math.round(reg.time))
      love.audio.stop(reg.source)
      reg.source = nil
      Regs[key] = nil
      Debug.note("soundmanager|"..key, nil) -- remove from notes
      GC.request()
    else
      -- This source registration is still good
      Debug.note("soundmanager|"..key, reg.time)
    end
  end
  Time = Time + dt
end

function soundmanager.pause()
  if not _paused then
    -- TODO pause all the sources
    for key,reg in pairs(Regs) do
      if not reg.source.pause then
        error("Source no pause? "..tflatten(reg.source))
      end
      reg.source:pause()
      _pausedSources[key] = reg.source
    end
    _paused = true
  end
end

function soundmanager.unpause()
  if _paused then
    _paused = false
    for key,reg in pairs(Regs) do
      if _pausedSources[key] then
        reg.source:play()
        _pausedSources[key] = nil
      end
    end
  end
end

return soundmanager
