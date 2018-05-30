return function()
  return {
    type = "research",
    cost = {material=400,crew=25},
    fow = 0.5,
    crew = 25,
    size = 32,
    speed = 50,
    health = {max = 25,},
    repair = false,
    actions = {
      "salvage","repair",
      "upgrade_speed",
      "upgrade_armor",
      "upgrade_damage",
      "upgrade_repair",
      "upgrade_range",
    },
    build_time = 20,
  }
end
