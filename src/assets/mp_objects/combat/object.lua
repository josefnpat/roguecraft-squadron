return function()
  return {
    type = "combat",
    class = libs.net.classTypes.military,
    military_large = true,
    cost = {material=250,crew=50},
    points = 4,
    crew = 50,
    size = 32,
    speed = 75,
    health = {max = 50,},
    shoot = {
      type = "missile",
      reload = 0.25*10,
      damage = 2*10,
      speed = 200,
      range = 200,
      aggression = 400,
    },
    build_time = 20,
    unlock_cost = 30,
  }
end
