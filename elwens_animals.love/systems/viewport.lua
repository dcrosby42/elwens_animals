-- Update viewport position based on its viewportTarget
return defineUpdateSystem(hasComps('viewport'), function(e,estore,input,res)
  estore:seekEntity(hasComps('viewportTarget','pos'),function(targetE)
    if e.viewport.targetName ~= '' then
      -- (only verify name match if viewport.targetName is set, otherwise we roll with the first hit)
      if e.viewport.targetName ~= targetE.viewportTarget.name then
        return false -- continue seekEntity
      end
    end

    -- Apply position update:
    e.viewport.x = targetE.pos.x + targetE.viewportTarget.offx
    e.viewport.y = targetE.pos.y + targetE.viewportTarget.offy

    return true -- end seekEntity
  end)
end)
