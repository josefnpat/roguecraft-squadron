return function()
  return {
    type = "enemy_combat",
    cost = {material=250,crew=50},
    crew = 50,
    size = 32,
    speed = 75,
    health = {max = 50,},
    shoot = {
      type = "laser",
      reload = 0.25,
      damage = 2,
      speed = 200,
      range = 200,
      aggression = 400,
    },
    build_time = 20,
  }
end
