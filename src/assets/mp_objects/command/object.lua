return function()
  return {
    type = "command",
    cost = {material=1000,crew=100},
    fow = 0.5,
    crew = 100,
    size = 64,
    speed = 150,
    health = {max = 150,},
    material = 600,
    construction_command = true,
    actions = {
      "build_scout",
      "build_salvager",
      "build_habitat",
      "build_drydock",
      "build_advdrydock",
    },
    build_time = 60,
  }
end
