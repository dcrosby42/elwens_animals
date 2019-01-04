local EcsAdapter = require 'modules.ecsadapter'
local EstoreModule = require 'modules.snowman2.estoremodule'

-- Adapts a Crozeng-style module to an ECS-style module:
return EcsAdapter(EstoreModule) 
