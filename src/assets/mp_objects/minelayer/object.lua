return function()
  return {
    type = "minelayer",
    cost = {material=150,crew=15},
    crew = 15,
    size = 32,
    speed = 50,
    health = {max = 15,},
    repair = false,
    actions = {
      "salvage","repair",
      "build_mine",
    },
    build_time = 30,
  }
end