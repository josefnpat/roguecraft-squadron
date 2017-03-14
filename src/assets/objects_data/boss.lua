return function()
  return {
    type = "boss",
    display_name = "Gigantic Enemy Battleship",
    info = "A truly fearsome enemy. Handle with extreme caution.",
    cost = {material=1000,crew=250},
    crew = 250,
    size = 64,
    speed = 100,
    health = {max = 500,},
    shoot = {
      reload = 0.125,
      damage = 4,
      speed = 200,
      range = 400,
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
