local Pool = require("pool")

local SoundPool = {}

function SoundPool:new(poolConf)
  local o = {
    _pool = Pool:new(poolConf)
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function SoundPool:getSource()
  return self._pool:get()
end

function SoundPool:releaseSource(source)
  return self._pool:put(source)
end

function SoundPool:getSourceDuration()
  local source = self:getSource()
  local dur = source:getDuration()
  self:releaseSource(source)
  return dur
end

function SoundPool.music(opts)
  local nameOrData = opts.data or opts.file or error("SoundPool.music() needs data or file option")
  local sp =
    SoundPool:new(
    {
      initSize = 1,
      incSize = 1,
      init = function()
        return love.audio.newSource(nameOrData, "stream")
      end,
      reset = function(source)
        source:stop()
      end
    }
  )
  return sp
end

function SoundPool.soundEffect(opts)
  local nameOrData = opts.data or opts.file or error("SoundPool.music() needs data or file option")
  local sp =
    SoundPool:new(
    {
      initSize = 2,
      mulSize = 2, -- double capacity on each expansion
      incSize = 0,
      init = function()
        return love.audio.newSource(nameOrData, "static")
      end,
      reset = function(source)
        source:stop()
      end
    }
  )
  return sp
end

return SoundPool
