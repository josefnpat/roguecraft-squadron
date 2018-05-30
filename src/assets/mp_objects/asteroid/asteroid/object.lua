return function()
  return {
    type = "asteroid",
    variation = math.random(0,4),
    size = 32,
    ore_supply = math.random(125,175),
    rotate = (math.random(0,1)*2-1)/10,
    pc = false,
  }
end
