return function()
  return {
    type = "advdrydock",
    display_name = "Advanced Dry Dock",
    info =  "A construction ship that can build advanced ships.",
    cost = {
      material=400,
      crew=30,
    },
    fow = 0.5,
    crew = 30,
    size = 48,
    speed = 50,
    health = {max = 50,},
    repair = false,
    actions = {
      "salvage","repair","upgrade_build_time",
      "build_jump",
      "build_radar",
      "build_tank",
      "build_artillery",
      "build_research",
    },
    build_time = 20,
  }
end
