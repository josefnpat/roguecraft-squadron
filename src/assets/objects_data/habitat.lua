return function()
  return {
    type = "habitat",
    display_name = "Habitat",
    info = "A bio-dome that produces food.",
    cost = {material=105,crew=5},
    crew = 5,
    size = 32,
    speed = 50,
    health = {max = 5,},
    food = 50,
    food_gather = 40,
    repair = false,
    actions = {"salvage","repair"}
  }
end
