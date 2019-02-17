local Events = require('eventhelpers')


local S = {}

local function handleState(evt,mario,e,estore,input,res)
  local fn = S[mario.mode][evt.action]
  if fn then
    fn(evt,mario,e,estore,input,res)
  end
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

S.standing = {

  leftx = function(evt,mario,e,estore,input,res)
    if evt.value < 0 then
      mario.facing = "left"
      mario.mode = "running"

    elseif evt.value > 0 then
      mario.facing = "right"
      mario.mode = "running"
    else
      
    end
    mario.value = evt.value
  end,

  jump = function(evt,mario,e,estore,input,res)
    if evt.value > 0 then
      print("jump")
      e.vel.dy = e.vel.dy - 100
      mario.mode = "jumping"
    end
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
  leftx = function(evt,mario,e,estore,input,res)
    if evt.value < 0 then
      mario.facing = "left"
    elseif evt.value > 0 then
      mario.facing = "right"
    else
      mario.mode = "standing"
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

local runSpeed = 300
local walkSpeed = 175
local gravity = 9.8
-- local walkSpeed = runSpeed
local function update(estore,input,res)
  local events = input.events
  
  estore:walkEntities(hasName('mario'), function(e)
    -- Process controller events
    for _,evt in ipairs(events) do
      if evt.type == "controller" and evt.id == e.controller.id then
        handleState(translateEvent(evt), e.mario, e, estore, input, res)
      end
    end

    -- Update animation
    local motion = "stand"
    local speed = 0 -- XXX
    if e.mario.mode == "running" then
      if e.mario.dash then
        motion = "run"
        speed = runSpeed  -- XXX
      else
        motion = "walk"
        speed = walkSpeed  -- XXX
      end
    end
    -- XXX:
    if e.mario.facing == "left" then
      speed = -speed
    end

    local animId = "mario_big_"..motion.."_"..e.mario.facing
    local timer = e.timers[e.anim.name]
    if e.anim.id ~= animId then
      e.anim.id = animId
      timer.t = 0
    end
    timer.factor = math.abs(e.mario.value)
    speed = speed * math.abs(e.mario.value)

    e.vel.dx = speed
    e.vel.dy = e.vel.dy + gravity

    e.pos.x = e.pos.x + (input.dt * e.vel.dx)
    e.pos.y = e.pos.y + (input.dt * e.vel.dy)

    local floor  = love.graphics.getHeight() - 50
    if e.pos.y > floor then 
      e.pos.y = floor
      e.vel.dy = 0
    end

  end)
end

return {
  system=update,
}
