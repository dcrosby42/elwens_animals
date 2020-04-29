local Events = require("eventhelpers")

local MoveX = "movex"
local Jump = "jump"
local Dash = "dash"
local JoystickActionMapping = {
  leftx = MoveX,
  face3 = Jump,
  face4 = Dash
}

local RunTopSpeed = 400
local WalkTopSpeed = 200
local BrakeForce = (0.8 / 0.016)
local WalkForce = (50 / 0.016)
local LateralAirForce = (50 / 0.016)
local Accel = 1500
local JumpVel = -300
local AirDriftForce = 400

local S = {}

local function translateEvent(evt)
  local action = (JoystickActionMapping[evt.action] or evt.action)
  local value = evt.value or 0
  return action, value
end

local function touchingDown(e)
  if e.contacts then
    for _, contact in pairs(e.contacts) do
      if contact.ny > 0 then
        return true
      end
    end
  end
  return false
end

local function setAnim(anim, id)
  if anim.id ~= id then
    anim.id = id
    anim.t = anim.reset
  end
end

local function setMarioAnim(e, verb)
  setAnim(e.anims.mario, "mario_big_" .. verb .. "_" .. e.mario.facing)
end

local function brake(e, dt)
  e.force.fx = 0
  e.vel.dx = dt * BrakeForce * e.vel.dx
  if math.abs(e.vel.dx) < 5 then
    -- squelch small vel noise
    e.vel.dx = 0
  end
end

local function stopMario(e, dt)
  brake(e, dt)
  -- setMarioAnim(e, "stand")
end

local function moveMario(e, dt)
  if e.mario.value / e.vel.dx < 0 then
    -- Desired move direction is counter to actual current velocity,
    -- so provide assistive brake.
    brake(e, dt)
  end
  if e.vel.dx < 0 then
    e.mario.facing = "left"
  elseif e.vel.dx > 0 then
    e.mario.facing = "right"
  end
  e.force.fx = e.mario.value * WalkForce * dt
end

local function moveMarioInAir(e, dt)
  -- if e.mario.value / e.vel.dx < 0 then
  -- Desired move direction is counter to actual current velocity,
  -- so provide assistive brake.
  -- brake(e, dt)
  -- end
  if e.vel.dx < 0 and e.mario.value < 0 then
    e.mario.facing = "left"
  elseif e.vel.dx > 0 and e.mario.value > 0 then
    e.mario.facing = "right"
  end
  e.force.fx = e.mario.value * LateralAirForce * dt
end

local function handleEvent(evt, e, _estore, input, _res)
  local action, value = translateEvent(evt)
  if action == MoveX then
    e.mario.value = value
  elseif action == Dash then
    if value == 1 then
      e.mario.dash = true
    else
      e.mario.dash = false
    end
  elseif action == Jump then
    if e.mario.touchingdown and value == 1 then
      e.mario.jump = true
      local boost = (math.abs(e.vel.dx) / RunTopSpeed) * -50
      e.vel.dy = JumpVel + boost
    -- ? needed? e.force.fx = 0
    end
    if value == 0 then
      if e.vel.dy < 0 then
        e.vel.dy = 0
      end
      e.mario.jump = false
    end
  end
end

local function update(estore, input, res)
  local events = input.events

  estore:walkEntities(
    hasName("mario"),
    function(e)
      -- update contact state
      e.mario.touchingdown = touchingDown(e)

      -- Process controller events
      for _, evt in ipairs(events) do
        if evt.type == "controller" and evt.id == e.controller.id then
          handleEvent(evt, e, estore, input, res)
        end
      end

      -- Update motion
      if e.mario.touchingdown then
        if e.mario.value ~= 0 then
          moveMario(e, input.dt)
        else
          stopMario(e, input.dt)
        end
        if math.abs(e.vel.dx) < 8 then
          setMarioAnim(e, "stand")
        else
          setMarioAnim(e, "walk")
        end
      else
        if e.mario.value ~= 0 then
          moveMarioInAir(e, input.dt)
        else
          e.force.fx = 0
        end
        if e.vel.dy < 0 and e.mario.jump then
          setMarioAnim(e, "jump")
        else
          setMarioAnim(e, "fall")
        end
      end
      e.timers.mario.factor = 1
      if e.mario.touchingdown then
        -- decide top speed
        local maxSpd = WalkTopSpeed
        if e.mario.dash then
          maxSpd = RunTopSpeed
        end
        -- limit speed
        if e.vel.dx > maxSpd then
          e.vel.dx = maxSpd
        elseif e.vel.dx < -maxSpd then
          e.vel.dx = -maxSpd
        end
      else
        -- air limits
        local maxSpd = RunTopSpeed
        if e.vel.dx > maxSpd then
          e.vel.dx = maxSpd
        elseif e.vel.dx < -maxSpd then
          e.vel.dx = -maxSpd
        end
      end
      if math.abs(e.vel.dx) > WalkTopSpeed then
        -- speed up the running anim
        e.timers.mario.factor = 2
      end
    end
  )
end

return {
  system = update
}
