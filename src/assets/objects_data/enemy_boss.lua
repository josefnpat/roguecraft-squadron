return function()
  return {
    type = "enemy_boss",
    display_name = "Gigantic Enemy Battleship",
    info = "A truly fearsome enemy. Handle with extreme caution.",
    cost = {material=1000,crew=250},
    crew = 250,
    size = 64,
    speed = 150,
    health = {max = 2000,},
    shoot = {
      reload = 0.125,
      damage = 8,
      speed = 200,
      range = 450,
      aggression = 800,
      sfx = {
        construct = "laser",
        destruct = "collision"
      },
    },
    repair = false,
    actions = {"salvage","repair"},
    jump_disable = true,
  }
end
