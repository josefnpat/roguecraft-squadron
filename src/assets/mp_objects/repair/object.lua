return function()
  return {
    type = "repair",
    class = libs.net.classTypes.support,
    cost = {material=150,crew=100},
    points = 6,
    fow = 0.5,
    crew = 100,
    size = 32,
    speed = 50,
    health = {max = 15,},
    repair = 10,
    actions = {},
    build_time = 5,
    unlock_cost = 30,
  }
end
