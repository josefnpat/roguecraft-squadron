return function()
  return {
    type = "command",
    cost = {material=1000,crew=100},
    fow = 0.5,
    crew = 100,
    size = 64,
    speed = 150,
    health = {max = 75,},
    material = 600,
    repair = false,
    actions = {
      "salvage","repair",
      "build_turret_small",
      "build_salvager",
      "build_habitat",
      "build_drydock",
      "build_advdrydock",
    },
    build_time = 60,
  }
end
