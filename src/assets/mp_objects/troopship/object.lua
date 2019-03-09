return function()
  return {
    type = "troopship",
    class = libs.net.classTypes.support,
    cost = {material=50,crew=100},
    points = 2,
    fow = 0.75,
    crew = 100,
    size = 16,
    speed = 100,
    health = {max = 10,},
    takeover = true,
    build_time = 10,
    unlock_cost = 15,
  }
end
