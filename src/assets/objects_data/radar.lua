return function()
  return {
    type = "radar",
    cost = {material=100,crew=5},
    fow = 2,
    crew = 5,
    size = 32,
    speed = 75,
    health = {max = 10,},
    repair = false,
    actions = {"salvage","repair","upgrade_fow"},
    build_time = 2,
  }
end
