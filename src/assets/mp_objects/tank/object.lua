return function()
  return {
    type = "tank",
    class = libs.net.classTypes.military,
    military_large = true,
    cost = {material=125,crew=25},
    points = 2,
    crew = 25,
    size = 32,
    speed = 100,
    health = {max = 600,},
    shoot = {
      type = "missile",
      reload = 0.125*10,
      damage = 0.25*20,
      speed = 200,
      range = 50,
      aggression = 400,
    },
    build_time = 30,
    unlock_cost = 60,
  }
end
