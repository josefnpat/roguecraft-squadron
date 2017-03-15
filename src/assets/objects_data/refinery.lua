return function()
  return {
    type = "refinery",
    display_name = "Refinery",
    info ="A material refining ship with some material storage.",
    cost = {material=110,crew=10},
    fow = 0.5,
    crew = 10,
    size = 32,
    speed = 50,
    health = {max = 10,},
    material = 50,
    material_gather = 5,
    repair = false,
    refine = true,
    actions = {"salvage","repair","refine"},
    build_time = 5,
  }
end
