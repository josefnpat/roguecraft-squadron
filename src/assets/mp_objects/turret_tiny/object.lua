return function()
  return {
    type = "turret_tiny",
    class = libs.net.classTypes.military,
    military_small = true,
    cost = {material=60,crew=10},
    points = 1,
    crew = 10,
    size = 16,
    health = {max = 10,},
    fow = 1.5,
    shoot = {
      type = "missile",
      reload = 0.25*2.5,
      damage = 0.5*1.25,
      speed = 400,
      range = 600,
      aggression = 400,
    },
    build_time = 10,
    subdangle_speed = 0,
    rotate = 0.5,
    default_level = 1,
  }
end
