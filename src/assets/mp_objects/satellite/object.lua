return function()
  return {
    type = "satellite",
    cost = {material=25},
    variation = math.random(0,2),
    fow = 2,
    size = 8,
    build_time = 2.5,
    health = {max = 5,},
  }
end
