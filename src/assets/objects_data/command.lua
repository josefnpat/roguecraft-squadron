return function()
  return {
    type = "command",
    display_name = "Command Ship",
    info =  "A basic construction ship with some ore and material storage and bio-production.",
    cost = {material=1000,crew=100},
    fow = 0.5,
    crew = 100,
    size = 64,
    speed = 50,
    health = {max = 75,},
    ore = 400,
    material = 400,
    repair = false,
    actions = {
      "salvage","repair","jump",
      "build_salvager",
      "build_habitat",
      "build_fighter",
      "build_drydock",
    },
  }
end
