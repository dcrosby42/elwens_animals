local F = {}

--
-- HIGHER ORDER FUNCS
--
function F.comp(f,g)
  return function(x) return f(g(x)) end
end

-- TODO this could be rewritten using iteration
function F.compn(fns)
  if #fns == 0 then return ident end
  local f1 = table.remove(fns,1)
  if #fns == 0 then
    return f1
  end
  return F.comp(f1, F.compn(fns))
end

function F.combine(fns)
  return function(x)
    local y = 0
    for i=1,#fns do
      y = y + fns[i](x)
    end
    return y
  end
end

function F.apply(xs, fn)
  local data = {}
  for i=1,#xs do
    table.insert(data, xs[i])
    table.insert(data, fn(xs[i]))
  end
  return data
end

--
-- UTILITY
--
function F.clip(val, low,high)
  if val < low or val > high then return 0 end
  return val
end

function F.genRange(from,to,step)
  step = step or 1
  local l = {}
  for i=from,to,step do
    table.insert(l,i)
  end
  return l
end

function F.genSeries(from,to,step,fn)
  step = step or 1
  local ser = {}
  for x=from,to,step do
    table.insert(ser,x)
    table.insert(ser,fn(x))
  end
  return ser
end

--
-- BASIC FUNCS
--

function F.ident(x) return x end

function F.constant(x)
  return function(_) return x end
end

F.one = F.constant(1)


function F.add(n)
  return function(x) return x + n end
end

function F.mult(n)
  return function(x) return x * n end
end

function F.sigmoid(x)
  return 1 / (1 + (math.exp(-x)))
end

function F.sigmoid1(x)
  return F.sigmoid((x - 0.5) * 10)
end
--
-- sig2 = compn({sig, mult(10),add(-0.5)})

-- local mySig = compn({sig, mult(10),add(-0.5)}) -- (0,0)->(1,1) smooth-step activation curve

return F

