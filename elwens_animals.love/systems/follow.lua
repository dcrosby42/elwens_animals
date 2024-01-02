return defineUpdateSystem(hasComps('follow', 'pos'), function(e, estore, input, res)
    local targetE = findEntity(estore, hasName(e.follow.targetName))
    if targetE then
        e.pos.x = targetE.pos.x + e.follow.offx
        e.pos.y = targetE.pos.y + e.follow.offy
    end
end)
