
local A = 48271
local B = 2147483647 -- 2^31 - 1

local function nextState(s)
  return (s * A) % B
end

local function churnState(s,n)
  for i=1,n do
    s = nextState(s)
  end
  return s
end

local function randomFloat(s)
  local s1 = nextState(s)
  return s1/B, s1
end

local function randomInt(s, lo,hi)
  local f,s1 = randomFloat(s)
  return math.floor(f * (hi-lo+1)) + lo, s1
end

local function randomChance(s, w)
  w = w or 0.5
  local f,s1 = randomFloat(s)
  return (f <= w), s1
end

local function pickRandom(s, list)
  local i, s1 = randomInt(s, 1, #list)
  return list[i], s1
end

local function localRandom(seed, x,y)
  local num = seed * math.floor(math.pow(love.math.noise(x/10,y/10)*10000,2))
  num = churnState(num,2)
  return num
end

-- local Rng = {
-- }
--
-- function Rng:new(s)
--   local o = {
--     s=s,
--   }
--   setmetatable(o, self)
--   self.__index = self
--   return o
-- end
--
-- function Rng:nextState()
--   self.s = nextState(self.s)
-- end
--
-- function Rng:setState(s)
--   self.s = s
-- end
--
-- function Rng:getState()
--   return self.s
-- end
--
-- function Rng:randomFloat()
--   local f
--   f, self.s = nextState(self.s)
--   return f
-- end


return {
  nextState = nextState,
  churnState = churnState,
  randomFloat = randomFloat,
  randomInt = randomInt,
  randomChance = randomChance,
  pickRandom = pickRandom,
  localRandom = localRandom,
  -- new = function(s) return Rng:new(s) end,
}



