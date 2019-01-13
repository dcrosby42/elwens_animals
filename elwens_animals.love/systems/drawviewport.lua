local Debug=require('mydebug').sub("Viewport",true,true)
local G = love.graphics

local DrawViewport = {}

local function getViewportComp(estore)
  local vpE
  estore:seekEntity(hasComps('viewport'), function(e)
    vpE = e
    return true
  end)
  if vpE then return vpE.viewport end
  return nil
end


function DrawViewport.update(estore,input,res)
  local vp = getViewportComp(estore)
  if not vp then return end
  estore:seekEntity(hasComps('viewportTarget','pos'),function(e)
    local tx,ty = getPos(e)
    vp.x = tx + e.viewportTarget.offx
    vp.y = ty + e.viewportTarget.offy
    return true
  end)
end

function DrawViewport.drawIn(estore,res)
  local vp = getViewportComp(estore)
  if not vp then return end
  G.push()
  G.translate(-vp.x, -vp.y)
  G.scale(vp.sx, vp.sy)
end

function DrawViewport.drawOut(estore,res)
  local vp = getViewportComp(estore)
  if not vp then return end
  G.pop()
end

return DrawViewport
