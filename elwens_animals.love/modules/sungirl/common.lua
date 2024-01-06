local Debug = require('mydebug').sub('Common', true)

local C = {}



function C.removePlayerTag(e)
  if e.tags.player then
    e:removeComp(e.tags.player)
  end
end

function C.addPlayerTag(e)
  if not e.tags.player then
    e:newComp('tag', { name = 'player' })
  end
end

function C.resetControls(e)
  for _, attr in ipairs({ 'left', 'right', 'up', 'down', 'jump' }) do
    e.player_control[attr] = false
  end
end

function C.swapOrder(e1, e2)
  -- Debug.println("swapOrder\n" .. tdebug(e1.parent) .. "\n" .. tdebug(e2.parent))
  local o1 = e1.parent.order
  local o2 = e2.parent.order
  e1.parent.order = o2
  e2.parent.order = o1
end

function C.swapPlayers(estore)
  local puppygirl = findEntity(estore, hasTag("puppygirl"))
  -- if puppygirl then
  --   Debug.println("found puppy girl")
  -- end
  local catgirl = findEntity(estore, hasTag("catgirl"))
  -- if puppygirl then
  --   Debug.println("found puppy girl")
  -- end

  C.resetControls(puppygirl)
  C.resetControls(catgirl)

  if puppygirl.tags.player then
    C.removePlayerTag(puppygirl)
    C.addPlayerTag(catgirl)
    C.swapOrder(catgirl, puppygirl)
    Debug.println('controlling catgirl')
  elseif catgirl.tags.player then
    C.removePlayerTag(catgirl)
    C.addPlayerTag(puppygirl)
    C.swapOrder(catgirl, puppygirl)
    Debug.println('controlling puppygirl')
  end

  local parentE = estore:getEntity(catgirl.parent.parentEid)
  parentE:resortChildren()
end

return C
