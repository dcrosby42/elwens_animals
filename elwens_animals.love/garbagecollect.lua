local Debug = (require('mydebug')).sub("GarbageCollect",false,false)
local GC = {}
local Thresh = 1
local State = {
  t=0,
  lastGC=0,
  requested=false,
}

-- Collect garbage if "needed", meaning: if GC has been requested and the debounce period is passed.
-- Intended to be invoked regularly (ie, once per update), but safe to call frequently since it's protected.
function GC.ifNeeded(dt)
  State.t = State.t + dt
  if State.requested and State.t - State.lastGC > Thresh then
    collectgarbage()
    State.lastGC = State.t
    State.requested = false
    Debug.println("collectgarbage() called; debounce threshold is "..Thresh)
  end
end

-- Notify of the need for GC; collectgarbage() will be invoked later via GC.ifNeeded() at the end of the update tick.
function GC.request()
  State.requested = true
end

return GC
