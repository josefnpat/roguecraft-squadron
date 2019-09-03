return function()
  return {
    type = "scout",
    class = libs.net.classTypes.military,
    military_small = true,
    cost = {material=50,crew=10},
    points = 1,
    count = 2,
    crew = 5,
    size = 16,
    speed = 400,
    health = {max = 1,},
    shoot = {
      type = "missile",
      reload = 2,
      damage = 1,
      speed = 300,
      range = 100,
      aggression = 400,
    },
    default_level = 1,
    build_time = 5,
    weight = 3,
  }
end
