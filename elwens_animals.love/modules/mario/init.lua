local EcsGameModule = require "ecs.gamemodule"

local resourceConfigs = loadfile('modules/mario/resources.lua')()

return EcsGameModule.new(resourceConfigs)
