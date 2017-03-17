return function()
  return {
    type = "fighter",
    display_name = "Fighter",
    info = "A small combat ship to defend your squadron with.",
    cost = {material=80,crew=15},
    fow = 0.75,
    crew = 15,
    size = 16,
    speed = 75,
    health = {max = 15,},
    shoot = {
      image = "missile",
      reload = 0.25,
      damage = 0.6,
      speed = 200,
      range = 150,
      aggression = 400,
      sfx = {
        construct = "laser",
        destruct = "collision"
      },
    },
    repair = false,
    actions = {"salvage","repair"},
    build_time = 2,
  }
end
