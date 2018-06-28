return function()
  return {
    type = "turret_large",
    cost = {material=500,crew=100},
    crew = 100,
    size = 64,
    health = {max = 200,},
    shoot = {
      image = "missile",
      reload = 0.25*10,
      damage = 8*10,
      speed = 800,
      range = 550,
      aggression = 800,
      sfx = {
        construct = "laser",
        destruct = "collision"
      },
    },
    repair = false,
    actions = {"salvage","repair"},
    build_time = 20,
  }
end
