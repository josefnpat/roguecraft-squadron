return function()
  return {
    type = "refinery",
    cost = {material=125,crew=10},
    fow = 0.5,
    crew = 10,
    size = 32,
    speed = 50,
    health = {max = 15,},
    material = 100,
    repair = false,
    refine = false,
    actions = {"salvage","repair","refine","upgrade_refine"},
    build_time = 5,
  }
end
