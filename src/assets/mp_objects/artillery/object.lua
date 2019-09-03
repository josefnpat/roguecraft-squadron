return function()
  return {
    type = "artillery",
    class = libs.net.classTypes.military,
    military_large = true,
    cost = {material=375,crew=50},
    points = 5,
    crew = 50,
    size = 32,
    speed = 50,
    health = {max = 25,},
    shoot = {
      type = "missile",
      reload = 0.125*1.5*10,
      damage = 4*1.5*10,
      speed = 400,
      range = 600,
      aggression = 400,
    },
    build_time = 30,
    unlock_cost = 60,
    weight = 3,
  }
end
