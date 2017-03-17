return function()
  return {
    type = "enemy_combat",
    variation = math.random(0,1),
    display_name = "Enemy Battlestar",
    info = "A combat ship.",
    cost = {material=250,crew=50},
    crew = 50,
    size = 32,
    speed = 75,
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
    actions = {"salvage","repair"},
    build_time = 20,
  }
end
