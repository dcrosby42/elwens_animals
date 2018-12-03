local M = {}

-- Iterate event objects, match event.type to eventType.
-- Handlers is a table whose string keys point to functions.
-- When an event matches, event.state is used to select the proper func from handlers.
function M.handle(events, eventType, handlers)
  for _,evt in ipairs(events) do
    if evt.type == eventType then
      local fn = handlers[evt.state]
      if fn then
        fn(evt)
      end
    end
  end
end

return M
