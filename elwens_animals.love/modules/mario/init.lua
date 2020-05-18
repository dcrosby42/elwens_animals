local EcsGameModule = require "ecs.gamemodule"
local Loaders = require "modules.mario.loaders"

return EcsGameModule.newFromFile('modules/mario/resources.lua', Loaders)
