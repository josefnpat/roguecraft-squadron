return function()
  return {
    type = "cargo",
    display_name = "Freighter",
    info = "A cargo ship that stores ore and material.",
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
