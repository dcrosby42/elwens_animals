local CircularBuffer = require 'circularbuffer'

local History = {}

function History:new(maxlen)
  local o = {
    _buffer=CircularBuffer.new(maxlen),
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function History:length()
  return #(self._buffer.history)
end

function History:push(data)
  self._buffer:push(data)
end

function History:get(i)
  local len = self:length()
  if len == 0 then return nil end
  -- CircularBuffer is ordered FILO so if we want i=1 to mean 
  -- the "beginning" of the list, or the "oldest" entry, we use reverse indexing.
  return self._buffer[len + 1 - i]
end

function History:getFilo(i)
  return self._buffer[i]
end

return History
