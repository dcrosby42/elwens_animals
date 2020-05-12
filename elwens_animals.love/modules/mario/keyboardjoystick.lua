-- Sample input structures for mapping and state
-- local mapping = {
--   axes={
--     w={"lefty",-1,"s"},
--     s={"lefty",1,"w"},
--     a={"leftx",-1,"d"},
--     d={"leftx",1,"a"},
--   },
--   buttons={
--     [","] = "face4",
--     ["."] = "face3",
--   },
-- }
-- local state = {
--   controllerId="joystick1",
-- }
-- Scans through events looking for key events that should generate
-- joystick events.
-- "events" will be modified by having more event objects concat'd to the end.
-- "state" will be modified by adding and removing keys that are pressed or released.
-- (btw state is required to help axis-related keys interact properly during overlapping press/release situations)
local function generateEvents(events, mapping, state)
  local outs = {}
  for i = 1, #events do
    local evt = events[i]
    if evt.type == "keyboard" then
      local action = mapping.buttons[evt.key]
      if action then
        state[evt.key] = (evt.state == "pressed")
        local v = 0
        if state[evt.key] then v = 1 end
        table.insert(outs, {
          type = "controller",
          id = state.controllerId,
          action = action,
          value = v,
        })
      else
        local def = mapping.axes[evt.key]
        if def then
          local axis, value, opposed = unpack(def)
          if evt.state == "pressed" then
            state[evt.key] = true
            if not state[oppposed] then
              -- normal situation: emit a "pressed" style event with our value.
              table.insert(outs, {
                type = "controller",
                id = state.controllerId,
                action = axis,
                value = value,
              })
            end
            -- If state[opposed] is true that means that the key for the other end of the axis is already down
            -- which means this current key cannot actually be pressed.
          else -- released
            if state[evt.key] then -- only think about "release" events when we know the key is actually down
              state[evt.key] = nil
              if state[opposed] then
                -- emit the opposing event
                local oppdef = mapping.axes[opposed]
                table.insert(outs, {
                  type = "controller",
                  id = state.controllerId,
                  action = oppdef[1],
                  value = oppdef[2],
                })
              else
                -- emit the 0 event
                table.insert(outs, {
                  type = "controller",
                  id = state.controllerId,
                  action = axis,
                  value = 0,
                })
              end
            end
          end
        end
      end
    end
  end
  tconcat(events, outs)
end

return {generateEvents = generateEvents}
