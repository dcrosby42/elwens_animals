local Events = require('eventhelpers')

local JoystickActionMapping = {
  face3="jump",
  face4="dash",
}

local RunTopSpeed = 400
local WalkTopSpeed = 280
local Brake = (0.8/0.016)
local Accel = 1500


local S = {}

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

local function setDash(evt,mario)
  if evt.value == 1 then 
    mario.dash = true
  else
    mario.dash = false
  end
end

local function startJumping(e)
  e.vel.dy = -500
  -- e.force.fy = -500
  e.force.fx = 0
  e.mario.mode = "jumping"
end

local function updateFacingValue(evt,mario)
  mario.value = evt.value
  if evt.value < 0 then
    mario.facing = "left"
  elseif evt.value > 0 then
    mario.facing = "right"
  end
end

local function brake(e,dt)
  e.force.fx = 0
  e.vel.dx = dt * Brake * e.vel.dx
  if math.abs(e.vel.dx) < 5 then e.vel.dx = 0 end
end

local function setAnim(anim,id)
  if anim.id ~= id then
    anim.id = id
    anim.t = anim.reset
  end
end

S.jumping = {
  dash = setDash,

  leftx = function(evt,mario,e,estore,input,res)
    updateFacingValue(evt,mario)
  end,

  jump = function(evt,mario,e,estore,input,res)
    if evt.value == 0 then
      e.vel.dy = 0
    end
  end,

  _update = function(mario,e,estore,input,res)
    if e.vel.dy >= 0 then
      e.force.fy = 0
      e.force.impy = 0 
      mario.mode = "falling"
    -- else
    --   e.force.fy = -1000 
    end
    setAnim(e.anims.mario,"mario_big_jump_"..e.mario.facing)
  end

}

S.falling = {
  dash = setDash,

  leftx = function(evt,mario,e,estore,input,res)
    updateFacingValue(evt,mario)
  end,

  _update = function(mario,e,estore,input,res)
    -- FIXME FIXME FIXME
    if e.pos.y >= 668 then
      e.vel.dy = 0
      brake(e,input.dt)
      if mario.value == 0 then
        mario.mode = "standing"
        e.vel.dx = 0
      else
        mario.mode = "running"
      end
      e.force.fy = 0
    else
      e.force.fy = 1000
    end

    setAnim(e.anims.mario,"mario_big_fall_"..e.mario.facing)
  end
}

S.standing = {
  dash = setDash,

  leftx = function(evt,mario,e,estore,input,res)
    updateFacingValue(evt,mario)
    if e.mario.value ~= 0 then
      mario.mode = "running"
    end
  end,

  jump = function(evt,mario,e,estore,input,res)
    if evt.value == 1 then
      startJumping(e)
    end
  end,

  _update = function(mario,e,estore,input,res)
    brake(e, input.dt)
    setAnim(e.anims.mario,"mario_big_stand_"..e.mario.facing)
  end,
}

S.running = {
  dash = setDash,

  jump = function(evt,mario,e,estore,input,res)
    if evt.value == 1 then
      startJumping(e)
    end
  end,

  leftx = function(evt,mario,e,estore,input,res)
    updateFacingValue(evt,mario)
    if e.mario.value == 0 then
      mario.mode = "standing"
    end
  end,

  _update = function(mario,e,estore,input,res)
    -- Adjust motion
    local maxSpd = WalkTopSpeed
    if e.mario.dash then
      maxSpd = RunTopSpeed
    end

    if math.abs(e.vel.dx) > maxSpd then
      -- artificial speed cap
      e.force.fx = 0
      brake(e, input.dt)
    else
      -- apply force to move mario
      e.force.fx = e.mario.value * Accel
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
    setAnim(e.anims.mario,"mario_big_"..verb.."_"..e.mario.facing)
  end,

}

local function update(estore,input,res)
  local events = input.events
  
  estore:walkEntities(hasName('mario'), function(e)
    -- Process controller events
    local mode = e.mario.mode
    for _,evt in ipairs(events) do
      if evt.type == "controller" and evt.id == e.controller.id then
        evt = translateEvent(evt)
        if S[mode][evt.action] then S[mode][evt.action](evt,e.mario,e,estore,input,res) end
        if e.mario.mode ~= mode then
          if S[mode]._exit then S[mode]._exit(evt.e.mario,e,estore,input,res)  end
          mode = e.mario.mode
          if S[mode]._enter then S[mode]._enter(evt,e.mario,e,estore,input,res) end
        end
      end
    end

    if S[mode]._update then S[mode]._update(e.mario,e,estore,input,res) end
  end)
end

return {
  system=update,
}
