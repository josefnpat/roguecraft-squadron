return function()
  return {
    type = "cargo",
    cost = {material=200,crew=10},
    fow = 0.5,
    crew = 10,
    size = 32,
    speed = 50,
    health = {max = 40,},
    ore = 200,
    material = 200,
    repair = false,
    actions = {"salvage","repair"},
    build_time = 10,
  }
end
