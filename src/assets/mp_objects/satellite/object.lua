return function()
  return {
    type = "satellite",
    cost = {material=10},
    variation = math.random(0,2),
    fow = 1,
    size = 8,
    build_time = 0.5,
    health = {max = 5,},
    cost = {material=5},
  }
end
