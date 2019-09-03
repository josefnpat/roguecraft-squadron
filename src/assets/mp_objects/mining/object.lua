return function()
  return {
    type = "mining",
    class = libs.net.classTypes.industrial,
    cost = {material=75,crew=10},
    points = 2,
    fow = 0.5,
    crew = 10,
    size = 32,
    speed = 75,
    health = {max = 10,},
    ore = 250,
    ore_gather = 25,
    build_time = 5,
    collect = true,
    unlock_cost = 15,
    weight = 3,
  }
end
