
return defineUpdateSystem(hasComps('viewport'), function(e,estore,input,res)
  local vp = e.viewport
  estore:seekEntity(hasComps('viewportTarget','pos'),function(targetE)
    if vp.targetName ~= '' then
      -- only verify name match if viewport.targetName is set
      if vp.targetName ~= targetE.viewportTarget.name then
        return false -- next seekEntity
      end
    end
    vp.x = targetE.pos.x + targetE.viewportTarget.offx
    vp.y = targetE.pos.y + targetE.viewportTarget.offy
    return true
  end)
end)
