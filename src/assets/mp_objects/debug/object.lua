return function()
  return {
    type = "debug",
    cost = {material=1000,crew=100},
    points = 0,
    fow = 8,
    crew = 100,
    size = 64,
    speed = 300,
    health = {max = 75,},
    material = 1600,
    shoot = {
      type = "laser",
      reload = 2.5,
      damage = 20,
      speed = 200,
      range = 600,
      aggression = 400,
    },
    actions = {
      "build_command",
    },
    build_time = 60,
  }
end
