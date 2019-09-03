return function()
  return {
    type = "refinery",
    class = libs.net.classTypes.industrial,
    cost = {material=125,crew=10},
    points = 3,
    fow = 0.5,
    crew = 10,
    size = 32,
    speed = 50,
    health = {max = 15,},
    material = 100,
    ore_convert = {rate=20,output="material"},
    build_time = 5,
    unlock_cost = 15,
    weight = 4,
  }
end
