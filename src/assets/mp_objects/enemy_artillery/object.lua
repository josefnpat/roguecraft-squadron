return function()
  return {
    type = "enemy_artillery",
    cost = {material=375,crew=50},
    crew = 50,
    size = 32,
    speed = 50,
    health = {max = 25,},
    shoot = {
      reload = 0.125*1.5,
      damage = 4*1.5,
      speed = 400,
      range = 400*1.5,
      aggression = 400,
      sfx = {
        construct = "laser",
        destruct = "collision"
      },
    },
    build_time = 30,
  }
end
