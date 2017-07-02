return function()
  return {
    type = "tank",
    cost = {material=125,crew=25},
    crew = 25,
    size = 32,
    speed = 50,
    health = {max = 400,},
    shoot = {
      image = "missile",
      reload = 0.125,
      damage = 0.25,
      speed = 200,
      range = 100,
      aggression = 400,
      sfx = {
        construct = "laser",
        destruct = "collision"
      },
    },
    repair = false,
    actions = {"salvage","repair"},
    build_time = 30,
  }
end
