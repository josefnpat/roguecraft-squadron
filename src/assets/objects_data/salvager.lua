return function()
  return {
    type = "salvager",
    cost = {material=25,crew=5},
    fow = 0.5,
    crew = 5,
    size = 32,
    speed = 50,
    health = {max = 5,},
    material = 10,
    material_gather = 15,
    repair = false,
    actions = {"salvage","repair","collect","upgrade_salvage"},
    collect = false,
    build_time = 1,
  }
end
