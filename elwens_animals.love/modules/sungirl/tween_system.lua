local Debug = require('mydebug').sub('Tween', true)
local easingFunctions = require("vendor.easing")

return defineUpdateSystem(hasComps("tween"), function(e, estore, input, res)
  local rems = {}

  for _, tween in pairs(e.tweens) do
    local subjectComp = e[tween.subject]
    -- if not subjectComp then Debug.println("No subjectComp for "..tween.subject.."?") end
    if not subjectComp then return end

    local timer = e.timers and (e.timers[tween.timer] or e.timers[tween.name])
    -- if not timer then Debug.println("No timer?") end
    if not timer then return end

    if not timer.alarm then
      for propName, params in pairs(tween.target) do
        local from, to, duration, funcname = unpack(params)

        local func = "linear"
        if funcname then
          func = easingFunctions[funcname]
        end

        local change = to-from
        local val = func(timer.t, from, change, duration)
        -- Debug.println(joinstrings({ tween.subject, ".", propName," ",funcname, "(", joinstrings({math.round(timer.t, 2), math.round(from), math.round(to), duration},", "), ") => ", val }))
        subjectComp[propName] = val
      end
    else
      -- This tween timer is kaput
      rems[timer.cid] = timer -- tracking as a set, to avoid dups
      rems[tween.cid] = tween
    end
  end

  -- Cleanup tweens and timers
  for _,comp in pairs(rems) do
    e:removeComp(comp)
  end

end)
