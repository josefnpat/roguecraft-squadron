return function()
  return {
    type = "advdrydock",
    cost = {
      material=400,
      crew=100,
    },
    fow = 0.5,
    crew = 100,
    size = 48,
    speed = 50,
    health = {max = 50,},
    repair = false,
    actions = {
      "salvage","repair","upgrade_build_time",
      "build_command",
      "build_jump",
      "build_radar",
      "build_tank",
      "build_artillery",
      "build_research",
    },
    build_time = 10,
  }
end
