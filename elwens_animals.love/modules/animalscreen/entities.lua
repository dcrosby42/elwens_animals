local Comps = require 'comps'
local Estore = require 'ecs.estore'

local Entities={}

function Entities.initialEntities(res)
  local estore = Estore:new()

  Entities.zooKeeper(estore,res)

  Entities.floor(estore,res)

  Entities.buttons(estore,res)

  return estore
end

function Entities.zooKeeper(estore,res)
  return estore:newEntity({
    {'tag',{name="zookeeper"}},
    {'pic', {id='background1', sx=1, sy=1.05}}, -- zoo_keeper.png is 731px tall, we want to stretch it to 768
    {'pos', {}},
    -- {'debug', {name='nextAnimal',value=1}},
    {'sound', {sound='bgmusic',loop=true,duration=res.sounds.bgmusic.duration}},
    {'physicsWorld', {gy=9.8*64,allowSleep=false}},
  })
end

function Entities.animal(estore, res, kind)
  return estore:newEntity({
    {'tag',{name="animal"}},
    {'pic', {id=kind, sx=0.5, sy=0.5, centerx=0.5, centery=0.5}}, 
    {'pos', {}},
    {'vel', {}},
    {'body', {}},
    {'force', {}},
    {'circleShape', {radius=50}},
  })
end

function Entities.floor(estore,res)
  return estore:newEntity({
    {'name', {name="floor"}},
    {'tag', {name='floor'}},
    {'body', {debugDraw=true, dynamic=false}},
		{'rectangleShape', {w=1024,h=50}},
    {'pos', {x=512,y=793}},
	})
end

function Entities.buttons(parent, res)
  Entities.nextModeButton(parent,res)
  Entities.quitButton(parent,res)
  Entities.toggleDebugButton(parent,res)
end

function Entities.quitButton(estore, res)
  return estore:newEntity({
    {'name', {name="power_button"}},
    {'pic', {id='power-button-outline', sx=0.25,sy=0.25,centerx=0.5, centery=0.5, color={1,1,1,0.25}}},
    {'pos', {x=980,y=50}},
    {'button', {kind='hold', eventtype='POWER', holdtime=0.5, radius=40}},
  })
end

function Entities.nextModeButton(estore, res)
  return estore:newEntity({
    {'name', {name="skip_button"}},
    {'pic', {id='skip-button-outline', sx=0.25,sy=0.25,centerx=0.5, centery=0.5, color={1,1,1,0.25}}},
    {'pos', {x=900,y=50}},
    {'button', {kind='hold', eventtype='SKIP', holdtime=0.5, radius=40}},
  })
end

function Entities.toggleDebugButton(estore, res)
  return estore:newEntity({
    {'name', {name="toggle_debug_button"}},
    -- {'pic', {id='skip-button-outline', sx=0.25,sy=0.25,centerx=0.5, centery=0.5, color={1,1,1,0.25}}},
    {'pos', {x=500,y=50}},
    {'button', {kind='hold', eventtype='TOGGLE_DEBUG', holdtime=0.5, radius=40}},
  })
end

function Entities.addSound(e, name, res)
  if not name then return end
  local cfg = res.sounds[name]
  if cfg then
    return e:newComp('sound', {
      sound=name,
      state='playing',
      duration=cfg.duration,
      volume=cfg.volume or 1,
    })
  else
    Debug.println("(No sound for "..tostring(name)..")")
    return nil
  end
end

return Entities

