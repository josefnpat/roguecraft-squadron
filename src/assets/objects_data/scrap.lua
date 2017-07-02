return function()
  return {
    type = "scrap",
    variation = math.random(0,5),
    size = 32,
    material_supply = math.random(10,30),
    rotate = (math.random(0,1)*2-1)/20,
    pc = false,
  }
end
