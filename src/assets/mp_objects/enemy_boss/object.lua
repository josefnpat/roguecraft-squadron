return function()
  return {
    type = "enemy_boss",
    cost = {material=1000,crew=250},
    crew = 250,
    size = 64,
    speed = 150,
    health = {max = 2000,},
    shoot = {
      type = "laser",
      reload = 0.125,
      damage = 8,
      speed = 200,
      range = 450,
      aggression = 800,
    },
    jump_disable = true,
  }
end
