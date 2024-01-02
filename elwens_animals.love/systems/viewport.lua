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
    local vx = targetE.pos.x + targetE.viewportTarget.offx
    local vy = targetE.pos.y + targetE.viewportTarget.offy

    if e.bounds then
      local left = e.bounds.offx
      local right = left + e.bounds.w
      local top = e.bounds.offy
      local bottom = top + e.bounds.h
      local vr = vx + e.viewport.w
      local vb = vy + e.viewport.h
      if vx < left then
        vx = left
      end
      if vr > right then
        vx = right - e.viewport.w
      end
      if vy < top then
        vy = top
      end
      if vb > bottom then
        vy = bottom - e.viewport.h
      end
    end

    e.viewport.x = vx * e.viewport.sx
    e.viewport.y = vy * e.viewport.sy

    return true -- end seekEntity
  end)
end)
