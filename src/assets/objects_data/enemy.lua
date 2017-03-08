return function()
  return {
    type = "enemy",
    display_name = "Enemy Battleship",
    info = "A fearsome enemy.",
    variation = math.random(0,2),
    cost = {material=250,crew=50},
    crew = 50,
    size = 32,
    speed = 100,
    health = {max = 50,},
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
