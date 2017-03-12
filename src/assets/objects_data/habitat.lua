return function()
  return {
    type = "habitat",
    display_name = "Habitat",
    info = "A bio-dome that produces food and can pick up crew from stations.",
    cost = {material=105,crew=5},
    fow = 0.5,
    crew = 5,
    crew_gather = 10,
    size = 32,
    speed = 50,
    health = {max = 5,},
    food = 50,
    food_gather = 40,
    repair = false,
    actions = {"salvage","repair"}
  }
end
