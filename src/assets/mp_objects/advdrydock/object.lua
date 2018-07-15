return function()
  return {
    type = "advdrydock",
    cost = {material=400,crew=100},
    fow = 0.5,
    crew = 100,
    size = 48,
    speed = 50,
    health = {max = 50,},
    actions = {
      "build_fighter",
      "build_combat",
      "build_artillery",
      "build_minelayer",
      "build_tank",
      "build_turret_small",
      "build_turret_large",
      -- "build_jump",
      -- "build_troopship",
    },
    build_time = 10,
  }
end
