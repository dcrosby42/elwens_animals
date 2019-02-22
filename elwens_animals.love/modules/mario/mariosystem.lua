local Events = require('eventhelpers')


local S = {}

local function handleState_2(evt,mario,e,estore,input,res)
  local mode = mario.mode
  if S[mario.mode][evt.action] then S[mario.mode][evt.action](evt,mario,e,estore,input,res) end
  if mode ~= mario.mode then
    if S[mode]._exit then S[mode]._exit(evt,mario,e,estore,input,res) end
    if S[mario.mode]._enter then S[mario.mode]._enter(evt,mario,e,estore,input,res) end
  end
  if S[mario.mode]._update then S[mario.mode]._update(evt,mario,e,estore,input,res) end
end

local JoystickActionMapping = {
  face3="jump",
  face4="dash",
}

local _event = { action='',value=0 }
local function translateEvent(evt)
  _event.action = (JoystickActionMapping[evt.action] or evt.action)
  _event.value = evt.value or 0
  return _event
end

local function updateDir(mario,evt)
  mario.value = evt.value
  if evt.value < 0 then
    mario.facing = "left"
  elseif evt.value > 0 then
    mario.facing = "right"
  end
end

S.standing = {
  leftx = function(evt,mario,e,estore,input,res)
    updateDir(mario,evt)
    if evt.value ~= 0 then
      mario.mode = "running"
    end
  end,

  jump = function(evt,mario,e,estore,input,res)
    -- if evt.value > 0 then
    --   print("jump")
    --   e.vel.dy = e.vel.dy - 100
    --   mario.mode = "jumping"
    -- end
  end,

  dash = function(evt,mario,e,estore,input,res)
    if evt.value > 0 then
      mario.dash = true
    else
      mario.dash = false
    end
  end,
}

S.running = {
  _update = function(_,mario,e,estore,input,res)
    e.force.fx = mario.value * 1000 * input.dt
  end,

  leftx = function(evt,mario,e,estore,input,res)
    updateDir(mario,evt)
    if mario.value == 0 then
      mario.mode = "standing"
    end
  end,

  dash = function(evt,mario,e,estore,input,res)
    -- if evt.value > 0 then
    --   mario.dash = true
    -- else
    --   mario.dash = false
    -- end
  end,
}

S.jumping = {
  leftx = function(evt,mario,e,estore,input,res)
    if evt.value < 0 then
      mario.facing = "left"
    elseif evt.value > 0 then
      mario.facing = "right"
    else
      
    end
    mario.value = evt.value
  end,

  dash = function(evt,mario,e,estore,input,res)
    if evt.value > 0 then
      mario.dash = true
    else
      mario.dash = false
    end
  end,
}

local function handleState(evt,mario,e,estore,input,res)
  if evt.action == "leftx" then
    mario.value = evt.value
    if evt.value < 0 then
      mario.facing = "left"
    elseif evt.value > 0 then
      mario.facing = "right"
    end
  elseif evt.action == "dash" then
    if evt.value == 1 then 
      mario.dashbutton = true
    else
      mario.dashbutton = false
    end
  end

end

local RunTopSpeed = 400
local WalkTopSpeed = 280
local Brake = (0.83/0.016)
local Accel = 1500

local function update(estore,input,res)
  local events = input.events
  
  estore:walkEntities(hasName('mario'), function(e)
    -- Process controller events
    for _,evt in ipairs(events) do
      if evt.type == "controller" and evt.id == e.controller.id then
        handleState(translateEvent(evt), e.mario, e, estore, input, res)
      end
    end

    -- Adjust motion
    local maxSpd = WalkTopSpeed
    local pace = 1
    -- local pace = 8
    if e.mario.dashbutton then
      maxSpd = RunTopSpeed
      -- pace = 2
    end

    if e.mario.value == 0 then
      e.force.fx = 0
      if e.vel.dx ~= 0 then
        e.vel.dx = input.dt * Brake * e.vel.dx
        if math.abs(e.vel.dx) < 5 then e.vel.dx = 0 end
      end
    else
      e.force.fx = e.mario.value * Accel
      if e.vel.dx > maxSpd then
        e.vel.dx = input.dt * Brake * e.vel.dx
        -- e.vel.dx = maxSpd
        e.force.fx = 0
      elseif e.vel.dx < -maxSpd then
        e.vel.dx = input.dt * Brake * e.vel.dx
        -- e.vel.dx = -maxSpd
        e.force.fx = 0
      end
    end
    if e.vel.dx > WalkTopSpeed then
      pace = 2
    end

    -- Update animation state
    local verb = "stand"
    local pace = 0
    if e.mario.value ~= 0 and e.vel.dx ~= 0 then 
      if e.mario.dashbutton then
        -- verb = "run" 
        verb = "walk" 
        pace = 2
      else
        verb = "walk" 
        pace = 1
      end
    end
   
    e.timers.mario.factor = pace
    local animId = "mario_big_"..verb.."_"..e.mario.facing
    if animId ~= e.anim.id then
      e.anim.id = animId
      -- if verb == "run" then
      --   e.timers.mario.t = e.timers.mario.t / 2
      -- elseif verb == "walk" then
      --   e.timers.mario.t = e.timers.mario.t * 2
      -- end
    end

  end)

end

return {
  system=update,
}
