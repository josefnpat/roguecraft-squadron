return function()
  return {
    type = "drydock",
    display_name = "Dry Dock",
    info =  "A construction ship with some ore and material storage and bio-production.",
    cost = {material=975,crew=100},
    crew = 100,
    size = 32,
    speed = 50,
    health = {max = 25,},
    ore = 400,
    material = 400,
    food = 100,
    food_gather = 10,
    repair = false,
    actions = {
      "salvage","repair",
      "build_drydock",
      "build_salvager",
      "build_mining",
      "build_refinery",
      "build_habitat",
      "build_combat",
      "build_cargo",
    },
  }
end
