return function()
  return {
    type = "minelayer",
    cost = {material=150,crew=15},
    points = 2,
    crew = 15,
    size = 32,
    speed = 50,
    health = {max = 15,},
    actions = {
      "build_mine",
    },
    build_time = 30,
  }
end
