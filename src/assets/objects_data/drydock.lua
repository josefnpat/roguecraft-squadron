return function()
  return {
    type = "drydock",
    display_name = "Dry Dock",
    info =  "A construction ship that can build basic ships.",
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
      "build_mining",
      "build_refinery",
      "build_cargo",
      "build_troopship",
      "build_combat",
      "build_advdrydock",
    },
    build_time = 10,
  }
end
