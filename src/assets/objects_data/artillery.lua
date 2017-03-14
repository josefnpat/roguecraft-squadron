return function()
  return {
    type = "artillery",
    display_name = "Artillery Vessel",
    info = "A long ranged combat ship to defend your squadron with.",
    cost = {material=200,crew=50},
    crew = 50,
    size = 32,
    speed = 50,
    health = {max = 15,},
    shoot = {
      reload = 0.5,
      damage = 3,
      speed = 200,
      range = 400,
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
