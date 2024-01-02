local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("SunGirl")

local HSpeed = 600

local function handleMovement(e, estore, input, res)
  e.vel.dx = 0
  e.vel.dy = 0

  if e.player_control.right then
    e.vel.dx = e.vel.dx + HSpeed
  end
  if e.player_control.left then
    e.vel.dx = e.vel.dx - HSpeed
  end

  -- SELECT ANIM
  local anim = e.anims.sungirl
  if e.vel.dx == 0 then
    anim.id = "sungirl_stand"
  else
    anim.id = "sungirl_run"
  end
  if e.vel.dx < 0 then
    e.states.dir.value = "left"
  else
    e.states.dir.value = "right"
  end

  -- ORIENT
  if e.states.dir.value == "left" then
    if anim.sx > 0 then
      anim.sx = -1 * anim.sx
    end
  else
    if anim.sx < 0 then
      anim.sx = -1 * anim.sx
    end
  end

  

  -- MOVE
  e.pos.x = e.pos.x + (input.dt * e.vel.dx)
  e.pos.y = e.pos.y + (input.dt * e.vel.dy)
end

return defineUpdateSystem(hasTag('sungirl'),
  function(e, estore, input,res)

    handleMovement(e,estore,input,res)

  -- EventHelpers.handle(input.events, 'keyboard', {
  --   pressed = function(event)
  --   end,
  -- })
  end
)
