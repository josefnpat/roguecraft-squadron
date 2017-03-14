return function()
  return {
    type = "habitat",
    display_name = "Habitat",
    info = "A bio-dome that produces crew and can pick up crew from stations.",
    cost = {material=105,crew=5},
    fow = 0.5,
    crew = 5,
    crew_gather = 10,
    crew_generate = 1,
    size = 32,
    speed = 50,
    health = {max = 5,},
    repair = false,
    actions = {"salvage","repair","collect"},
    collect = false,
  }
end
