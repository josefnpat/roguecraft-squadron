return function()
  return {
    type = "enemy_miniboss",
    cost = {material=500,crew=100},
    crew = 100,
    size = 48,
    speed = 100,
    health = {max = 100,},
    shoot = {
      type = "laser",
      reload = 0.125,
      damage = 4,
      speed = 200,
      range = 400,
      aggression = 800,
    },
    build_time = 20,
  }
end
