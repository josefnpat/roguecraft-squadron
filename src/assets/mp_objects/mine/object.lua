return function()
  return {
    type = "mine",
    class = libs.net.classTypes.military,
    cost = {material=25},
    points = 0,
    size = 16,
    build_time = 2.5,
    health = {max = 1200,},
    explode = {
      range = 100,
      damage_range = 200,
      damage = 50,
    },
    unlock_cost = 5,
  }
end
