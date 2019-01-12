local noise = love.math.noise

local N = {}


function N.octaveNoise(x, num_iterations, persistence, freq, low, high)
  local maxAmp = 0
  local amp = 1
  local nval = 0

  -- add successively smaller, higher-frequency terms
  for i=1,num_iterations do
    -- nval = nval + noise(x * freq, y * freq) * amp
    nval = nval + (noise(x * freq) - 0.5)*2 * amp
    maxAmp = maxAmp + amp -- accumulate the overall amplitude measure
    amp = amp * persistence -- shrink the amplitude for the next iter
    freq = freq * 2 -- double the frequency
  end

  -- normalize to 0-1
  nval = nval / maxAmp

  -- normalize to given range
  nval = nval * (high - low) / 2 + (high + low) / 2

  return nval
end

-- https://cmaher.github.io/posts/working-with-simplex-noise/
function N.octaveNoise2d(num_iterations, x, y, persistence, scale, low, high)
  local maxAmp = 0
  local amp = 1
  local freq = scale
  local nval = 0

  -- add successively smaller, higher-frequency terms
  for i=1,num_iterations do
    -- nval = nval + noise(x * freq, y * freq) * amp
    nval = nval + (noise(x * freq, y * freq) - 0.5)*2 * amp
    maxAmp = maxAmp + amp -- accumulate the overall amplitude measure
    amp = amp * persistence -- shrink the amplitude for the next iter
    freq = freq * 2 -- double the frequency
  end

  -- normalize to 0-1
  nval = nval / maxAmp

  -- normalize to given range
  nval = nval * (high - low) / 2 + (high + low) / 2

  return nval
end

return N
