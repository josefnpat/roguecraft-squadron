return function()
  return {
    type = "combat",
    military_large = true,
    cost = {material=250,crew=50},
    crew = 50,
    size = 32,
    speed = 75,
    health = {max = 50,},
    shoot = {
      image = "missile",
      reload = 0.25*10,
      damage = 2*10,
      speed = 200,
      range = 200,
      aggression = 400,
      sfx = {
        construct = "laser",
        destruct = "collision"
      },
    },
    build_time = 20,
  }
end
