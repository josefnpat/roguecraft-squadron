return function()
  return {
    type = "turret_small",
    cost = {material=125,crew=25},
    crew = 25,
    size = 32,
    health = {max = 50,},
    shoot = {
      image = "missile",
      reload = 0.25*10,
      damage = 2*10,
      speed = 400,
      range = 400,
      aggression = 400,
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
