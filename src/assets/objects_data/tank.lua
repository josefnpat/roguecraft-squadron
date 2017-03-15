return function()
  return {
    type = "tank",
    display_name = "Armored Frontline Tank",
    info = "A combat ship with a lot of health to defend your squadron with.",
    cost = {material=250,crew=25},
    crew = 25,
    size = 32,
    speed = 50,
    health = {max = 200,},
    shoot = {
      reload = 1,
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
    actions = {"salvage","repair"},
    build_time = 30,
  }
end
