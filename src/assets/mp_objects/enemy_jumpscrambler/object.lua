return function()
  return {
    type = "enemy_jumpscrambler",
    size = 32,
    rotate = (math.random(0,1)*2-1)/10,
    cost = {material=100,crew=10},
    crew = 10,
    health = {max=5},
    actions = {"salvage","repair"},
    jump_disable = true,
  }
end
