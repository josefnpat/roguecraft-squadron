return function()
  return {
    type = "cargo",
    display_name = "Freighter",
    info = "A cargo ship that stores ore and material.",
    cost = {material=345,crew=10},
    fow = 0.5,
    crew = 10,
    size = 32,
    speed = 50,
    health = {max = 40,},
    ore = 100,
    material = 100,
    repair = false,
    actions = {"salvage","repair"},
    build_time = 10,
  }
end
