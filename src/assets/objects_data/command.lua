return function()
  return {
    type = "command",
    display_name = "Command Ship",
    info =  "A basic construction ship with some material storage.",
    cost = {material=1000,crew=100},
    fow = cheat and 32 or 0.5,
    crew = 100,
    size = 64,
    speed = 50,
    health = {max = 75,},
    material = 1600,
    repair = false,
    actions = {
      "salvage","repair",
      "build_salvager",
      "build_habitat",
      "build_fighter",
      "build_drydock",
    },
  }
end
