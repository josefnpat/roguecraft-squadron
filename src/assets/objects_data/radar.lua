return function()
  return {
    type = "radar",
    display_name = "Radar Array",
    info = "A scanning ship with a large visual range.",
    cost = {material=200,crew=5},
    fow = 2,
    crew = 5,
    size = 32,
    speed = 100,
    health = {max = 20,},
    repair = false,
    actions = {"salvage","repair"},
    build_time = 2,
  }
end
