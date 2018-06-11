return function()
  return {
    type = "debug",
    cost = {material=1000,crew=100},
    fow = 2,
    crew = 100,
    size = 64,
    speed = 300,
    health = {max = 75,},
    material = 1600,
    repair = false,
    shoot = {
      image = "missile",
      reload = 2.5,
      damage = 20,
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
      "build_command",
    },
    build_time = 60,
  }
end
