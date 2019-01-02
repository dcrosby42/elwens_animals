local Engine = require 'crozeng/main'

Engine.module_name = 'modules/root'
-- Engine.module_name = 'modules/animalscreen'

Engine.onload = function()
  love.window.setMode(1024, 768, {
    -- fullscreen=true,
    resizable=true,
    minwidth=400,
    minheight=300,
    highdpi=false
  })
end

