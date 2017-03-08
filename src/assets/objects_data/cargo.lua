return function()
  return {
    type = "cargo",
    display_name = "Freighter",
    info = "A cargo ship that stores ore, material and food.",
    cost = {material=345,crew=10},
    crew = 10,
    size = 32,
    speed = 50,
    health = {max = 40,},
    ore = 100,
    material = 100,
    food = 100,
    repair = false,
    actions = {"salvage","repair"}
  }
end
