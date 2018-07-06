return function()
  return {
    type = "scout",
    cost = {material=50,crew=10},
    count = 2,
    crew = 5,
    size = 16,
    speed = 400,
    health = {max = 1,},
    shoot = {
      image = "missile",
      reload = 2,
      damage = 1,
      speed = 300,
      range = 100,
      aggression = 400,
      sfx = {
        construct = "laser",
        destruct = "collision"
      },
    },
    repair = false,
    actions = {"salvage","repair"},
    build_time = 5,
  }
end