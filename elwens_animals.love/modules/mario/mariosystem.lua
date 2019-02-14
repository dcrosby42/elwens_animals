local Events = require('eventhelpers')

local S = {}

local function handleState(evt,mario,e,estore,input,res)
  local fn = S[mario.mode][evt.action]
  if fn then
    fn(evt,mario,e,estore,input,res)
  end
end

local ActionMapping = {
  face3="jump",
  face4="dash",
}

local _event = { action='',value=0 }
local function translateEvent(evt)
  _event.action = (ActionMapping[evt.action] or evt.action)
  _event.value = evt.value or 0
  return _event
end

S.standing = {

  leftx = function(evt,mario,e,estore,input,res)
    if evt.value < 0 then
      mario.dir = "left"
      mario.mode = "running"

    elseif evt.value > 0 then
      mario.dir = "right"
      mario.mode = "running"
    else
      
    end
  end,

  jump = function(evt,mario,e,estore,input,res)
    if evt.value > 0 then
      print("jump")
    end
  end,

  dash = function(evt,mario,e,estore,input,res)
    if evt.value > 0 then
      mario.dash = true
      print("dash")
    else
      mario.dash = false
      print("undash")
    end
  end,
}

S.running = {
  leftx = function(evt,mario,e,estore,input,res)
    if evt.value < 0 then
      mario.dir = "left"
      -- mario.mode = "running"

    elseif evt.value > 0 then
      mario.dir = "right"
      -- mario.mode = "running"
    else
      mario.mode = "standing"
      
    end
  end,

  dash = function(evt,mario,e,estore,input,res)
    if evt.value > 0 then
      mario.dash = true
      print("dash")
    else
      mario.dash = false
      print("undash")
    end
  end,
}

local function update(estore,input,res)
  estore:walkEntities(hasName('mario'), function(e)
    -- Process controller events
    for _,evt in ipairs(input.events) do
      if evt.type == "controller" and evt.id == e.controller.id then
        handleState(translateEvent(evt), e.mario, e, estore, input, res)
      end
    end

    -- Update animation
    local motion = "stand"
    local speed = 0
    if e.mario.mode == "running" then
      if e.mario.dash then
        motion = "run"
        speed = 300 
      else
        motion = "walk"
        speed = 175 
      end
    end
    if e.mario.dir == "left" then
      speed = -speed
    end

    local animId = "mario_big_"..motion.."_"..e.mario.dir
    if e.anim.id ~= animId then
      e.anim.id = animId
      e.timers[e.anim.name].t = 0
    end

    e.pos.x = e.pos.x + (input.dt * speed)

  end)
end

return {
  system=update,
}
