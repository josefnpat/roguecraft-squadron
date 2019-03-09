return function()
  return {
    type = "habitat",
    class = libs.net.classTypes.industrial,
    cost = {material=100},
    points = 2,
    fow = 0.5,
    crew = 5,
    crew_gather = 10,
    crew_generate = 2,
    size = 32,
    speed = 50,
    health = {max = 5,},
    default_level = 1,
    build_time = 5,
    collect = true,
  }
end
