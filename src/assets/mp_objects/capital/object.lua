return function()
  return {
    type = "capital",
    military_large = true,
    cost = {material=4000,crew=800},
    points = 54,
    crew = 800,
    size = 128,
    speed = 75,
    health = {max = 800,},
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
    build_time = 320,
    subdangle_speed = 0.5,
    unlock_cost = 120,
  }
end