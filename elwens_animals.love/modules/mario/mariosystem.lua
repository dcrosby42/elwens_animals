local Events = require('eventhelpers')

local JoystickActionMapping = {
  face3="jump",
  face4="dash",
}

local RunTopSpeed = 400
local WalkTopSpeed = 280
local Brake = (0.83/0.016)
local Accel = 1500


local S = {}

local function handleState2(evt,mario,e,estore,input,res)
  local mode = mario.mode
  if S[mario.mode][evt.action] then S[mario.mode][evt.action](evt,mario,e,estore,input,res) end
  -- if mode ~= mario.mode then
  --   if S[mode]._exit then S[mode]._exit(evt,mario,e,estore,input,res) end
  --   if S[mario.mode]._enter then S[mario.mode]._enter(evt,mario,e,estore,input,res) end
  -- end
  if S[mario.mode]._update then S[mario.mode]._update(evt,mario,e,estore,input,res) end
end


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
  _update = function(evt,mario,e,estore,input,res)
  end,
  _update = function(evt,mario,e,estore,input,res)
  end,

  dash = function(evt,mario,e,estore,input,res)
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

local function brake(vel,dt)
  vel.dx = dt * Brake * vel.dx
  if math.abs(vel.dx) < 5 then vel.dx = 0 end
end

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
    if e.mario.dashbutton then
      maxSpd = RunTopSpeed
    end

    if e.mario.value == 0 then
      -- not trying to move
      e.force.fx = 0
      brake(e.vel, input.dt)
    else
      -- trying to move
      if math.abs(e.vel.dx) > maxSpd then
        -- artificial speed cap
        e.force.fx = 0
        brake(e.vel, input.dt)
      else
        -- push
        e.force.fx = e.mario.value * Accel
      end
    end

    -- Update animation state
    local verb = "stand"
    if e.mario.value ~= 0 and e.vel.dx ~= 0 then 
      verb = "walk" 
    end
    if math.abs(e.vel.dx) > WalkTopSpeed then
      e.timers.mario.factor = 2
    else
      e.timers.mario.factor = 1
    end
    local animId = "mario_big_"..verb.."_"..e.mario.facing
    if animId ~= e.anim.id then
      e.anim.id = animId
    end
  end)

end

return {
  system=update,
}
