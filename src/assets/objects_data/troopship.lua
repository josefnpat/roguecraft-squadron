return function()
  return {
    type = "troopship",
    cost = {material=50,crew=25},
    fow = 0.75,
    crew = 25,
    size = 16,
    speed = 150,
    health = {max = 15,},
    repair = false,
    takeover = 0.25,
    actions = {"salvage","repair"},
    build_time = 3,
  }
end
