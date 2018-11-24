return function()
  return {
    type = "scrap",
    size = 32,
    material_supply = math.random(100,300)*2,
    rotate = (math.random(0,1)*2-1)/20,
    pc = false,
  }
end
