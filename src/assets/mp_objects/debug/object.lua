return function()
  return {
    type = "command",
    cost = {material=1000,crew=100},
    fow = cheat and 32 or 0.5,
    crew = 100,
    size = 64,
    speed = 300,
    health = {max = 75,},
    material = 1600,
    repair = false,
    shoot = {
      image = "missile",
      reload = 0.25,
      damage = 2,
      speed = 200,
      range = 600,
      aggression = 400,
      sfx = {
        construct = "laser",
        destruct = "collision"
      },
    },
    actions = {
      "salvage","repair",
      "build_salvager",
      "build_habitat",
      "build_fighter",
      "build_drydock",
      "build_satellite",
    },
    build_time = 60,
  }
end
