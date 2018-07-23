return function()
  return {
    type = "turret_large",
    military_large = true,
    cost = {material=500,crew=100},
    crew = 100,
    size = 64,
    health = {max = 200,},
    shoot = {
      image = "missile",
      reload = 0.25*5,
      damage = 8*5,
      speed = 800,
      range = 500,
      aggression = 800,
      sfx = {
        construct = "laser",
        destruct = "collision"
      },
    },
    build_time = 20,
    subdangle_speed = 0,
    rotate = 0.5,
  }
end
