local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("PlayerControl")

local function mapKey(key)
  if key == "space" then
    return "action"
  end
  -- certain keys will just match up, like "left" "down" etc.
  return key
end

return defineUpdateSystem(
  allOf(hasTag('player'), hasComps('player_control')),
  function(e, estore, input, res)
    local con = e.player_control
    con.just_pressed = {}
    con.just_released = {}
    EventHelpers.handle(input.events, 'keyboard', {
      pressed = function(event)
        local key = mapKey(event.key)
        if con[key] ~= nil then
          if con[key] ~= true then
            con.just_pressed[key] = true
          end
          con[key] = true
        end
      end,

      released = function(event)
        local key = mapKey(event.key)
        if con[key] ~= nil then
          if con[key] == true then
            con.just_released[key] = true
          end
          con[key] = false
        end
      end,
    })
    con.any = con.left or con.right or con.up or con.down or con.jump
  end
)
