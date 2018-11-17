return function()
  return {
    type = "asteroid",
    size = 32,
    ore_supply = math.random(500,1500)*4,
    rotate = (math.random(0,1)*2-1)/10,
    pc = false,
  }
end
