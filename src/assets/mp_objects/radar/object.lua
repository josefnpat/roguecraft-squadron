return function()
  return {
    type = "radar",
    cost = {material=125,crew=5},
    fow = 2,
    crew = 5,
    size = 32,
    speed = 75,
    health = {max = 13,},
    actions = {
      "build_satellite",
    },
    build_time = 2,
  }
end
