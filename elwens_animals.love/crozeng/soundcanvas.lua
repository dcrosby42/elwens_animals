local Debug = require("mydebug").sub("soundcanvas")
local GC = require("garbagecollect")

local function getDuration(config, state)
  if state.duration and state.duration ~= "" and state.duration > 0 then
    return state.duration
  else
    return config.duration
  end
end

local SoundInfo = {}

-- Key string
-- Config{pool, volume, duration}
-- State{volume, playTime, duration, isLooping}
function SoundInfo:new(key, config, sound)
  local o = {
    key = key,
    config = config,
    lastTick = 0
  }
  -- -- and init the Source:
  -- if config.source then
  --   -- Source already provided, probably music
  --   o.source = config.source
  --   o.source:stop() -- reset, just in case
  -- elseif config.data then
  --   -- A SoundData is provided, probably a sound effect.
  --   o.source = love.audio.newSource(config.data)
  -- end
  o.source = config.pool:getSource()
  setmetatable(o, self)
  self.__index = self
  return o
end

-- Update playing sound Source to reflect given state
-- State{volume, playTime, duration, isLooping}
function SoundInfo:update(tick, state)
  if not self.lastState then
    -- This is the first time
    self:init(state)
  else
    -- Not the first time, do some updates
    self:sync(state)
  end
  self.lastTick = tick -- mark as "seen"
  self.lastState = state -- keep track of this state for comparison next time
end

-- First-time kickoff of new sound based on state.
-- State{volume, playTime, duration, isLooping}
function SoundInfo:init(state)
  self.source:setLooping(state.isLooping)
  self.source:setVolume(self.config.volume * state.volume)
  local pos = state.playTime % getDuration(self.config, state)
  self.source:seek(pos)
  if state.playState == "playing" then
    self.source:play()
  else
    self.source:pause()
  end
end

local PlayTimeLagTolerance = {
  music = 30 / 60,
  sound = 3 / 60
}

-- Update already-existing sound based on given state
-- State{volume, playTime, duration, isLooping}
function SoundInfo:sync(state)
  if state.playState == "playing" then
    if state.isLooping ~= self.lastState.isLooping then
      self.source:setLooping(state.isLooping)
    end
    if state.volume ~= self.lastState.volume then
      self.source:setVolume(self.config.volume * state.volume)
    end

    if state.playTime == self.lastState.playTime then
      -- sound component has not progressed since last time... assume circumstantial pause
      if self.source:isPlaying() then
        Debug.println("Circumstantial pause " .. self.key)
        self.source:pause()
      end
    elseif math.abs(state.playTime - self.source:tell("seconds")) > PlayTimeLagTolerance[self.config.type] then
      local dur = getDuration(self.config, state)
      if dur - state.playTime > 1 / 60 then -- don't get picky about end-of-sound sub-frame dif
        local diff = state.playTime - self.source:tell("seconds")
        Debug.println(
          self.key ..
            " TIME DIFF " ..
              diff ..
                " (tol for " ..
                  self.config.type ..
                    " is " ..
                      PlayTimeLagTolerance[self.config.type] ..
                        ") state.playTime=" ..
                          state.playTime .. " != source:tell()=" .. self.source:tell("seconds") .. " duration=" .. dur
        )
        local pos = state.playTime % dur
        self.source:seek(pos)
        if not self.source:isPlaying() then
          self.source:play()
        end
      end
    end
  else
    -- not playing
    if self.source:isPlaying() then
      Debug.println(self.key .. " not playing, goint to pause")
      self.source:pause()
    end
  end
end

function SoundInfo:release()
  self.source:stop()
  self.config.pool:releaseSource(self.source)
end

local SoundCanvas = {}

function SoundCanvas:new()
  local o = {
    tick = 0,
    sounds = {}
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

-- Mark the beginning of a real-world update.
-- Clients should call:
-- soundCanvas:startFrame()
-- soundCanvas:drawSound(...)
-- soundCanvas:drawSound(...)
-- soundCanvas:drawSound(...)
-- soundCanvas:endFrame()
function SoundCanvas:startFrame()
  self.tick = self.tick + 1
end

function SoundCanvas:endFrame()
  -- find any sounds that didn't receive an update this past tick
  local keysToRemove = {}
  for key, soundInfo in pairs(self.sounds) do
    if soundInfo.lastTick < self.tick then
      soundInfo:release()
      table.insert(keysToRemove, key)
    end
  end
  -- stop and remove sound
  for i = 1, #keysToRemove do
    Debug.println("Removing " .. keysToRemove[i])
    self.sounds[keysToRemove[i]] = nil
  end
end

-- Given info about a sound and its state, synchronize the reality to the desired state.
-- Should add,update,remove underlying sound Souce objects.
-- Key: string
-- Config: {pool, volume, duration}
-- State: {volume, playTime, duration, isLooping}
function SoundCanvas:drawSound(key, config, state)
  local sound = self.sounds[key]
  if not sound then
    -- start tracking this sound:
    sound = SoundInfo:new(key, config, state)
    self.sounds[key] = sound
    Debug.println("Added " .. key)
  end
  sound:update(self.tick, state)
end

SoundCanvas.default = SoundCanvas:new()

return SoundCanvas
