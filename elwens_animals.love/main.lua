local Engine = require 'crozeng/main'

love.physics.setMeter(64) --the height of a meter our worlds will be 64px

-- Engine.module_name = 'modules/root'
Engine.module_name = 'modules.ecsdev2wrapper'

Engine.onload = function()
  love.window.setMode(1024, 768, {
    -- fullscreen=true,
    resizable=true,
    minwidth=400,
    minheight=300,
    highdpi=false
  })
end

