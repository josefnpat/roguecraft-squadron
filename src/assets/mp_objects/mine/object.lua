return function()
  return {
    type = "mine",
    cost = {material=25},
    size = 16,
    build_time = 2.5,
    health = {max = 30,},
    explode = {
      range = 200,
      damage = 50,
    },
  }
end
