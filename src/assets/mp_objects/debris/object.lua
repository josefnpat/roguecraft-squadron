return function()
  return {
    type = "debris",
    size = 16,
    material_supply = 1, -- overridden
    rotate = (math.random(0,1)*2-1)/20,
    pc = false,
  }
end
