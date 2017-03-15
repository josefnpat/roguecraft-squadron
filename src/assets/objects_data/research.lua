return function()
  return {
    type = "research",
    display_name = "Research Facility",
    info = "A research ship used to advance your fleet.",
    cost = {material=400,crew=25},
    fow = 0.5,
    crew = 25,
    size = 32,
    speed = 50,
    health = {max = 20,},
    repair = false,
    actions = {"salvage","repair"},
    build_time = 10,
  }
end
