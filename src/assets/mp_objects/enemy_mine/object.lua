return function()
  return {
    type = "enemy_mine",
    size = 16,
    rotate = (math.random(0,1)*2-1),
    health = {max=5},
    minimap = false,
    detonate = {
      range = 32,
      damage = 9000,
    }
  }
end
