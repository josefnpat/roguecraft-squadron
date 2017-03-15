return function()
  return {
    type = "drydock",
    display_name = "Dry Dock",
    info =  "A construction ship that can build many types of ships.",
    cost = {
      material=200,-- used to be 400
      crew=15,
    },
    fow = 0.5,
    crew = 15,
    size = 32,
    speed = 50,
    health = {max = 25,},
    repair = false,
    actions = {
      "salvage","repair",
      "build_salvager",
      "build_habitat",
      "build_fighter",
      "build_drydock",
      "build_mining",
      "build_refinery",
      "build_research",
      "build_jump",
      "build_cargo",
      "build_radar",
      "build_combat",
      "build_tank",
      "build_artillery",
      "build_troopship",
    },
    build_time = 10,
  }
end
