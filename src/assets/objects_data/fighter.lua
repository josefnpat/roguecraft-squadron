return function()
  return {
    type = "fighter",
    display_name = "Fighter",
    info = "A small combat ship to defend your squadron with.",
    cost = {material=25,crew=5},
    crew = 5,
    size = 32,
    speed = 100,
    health = {max = 5,},
    shoot = {
      reload = 0.25,
      damage = 2,
      speed = 200,
      range = 200,
      aggression = 400,
      sfx = {
        construct = "laser",
        destruct = "collision"
      },
    },
    repair = false,
    actions = {"salvage","repair"}
  }
end
