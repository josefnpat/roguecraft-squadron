return function (i)

  -- Clamp
  if i > 1 then i = 1 end
  if i < 0 then i = 0 end

  -- 0 -> 0.5: 255
  -- 0.5 -> 1: 255 .. 0
  local r = 255*2 - 255*2*i
  if r > 255 then r = 255 end

  -- 0 -> 0.5: 0 .. 255
  -- 0.5 -> 1: 255
  local g = 255*2*i
  if g > 255 then g = 255 end

  -- 0 -> 1: 0
  local b = 0

  return {r,g,b}
end
