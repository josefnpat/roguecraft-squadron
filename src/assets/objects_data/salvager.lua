return function()
  return {
    type = "salvager",
    display_name = "Salvager",
    info = "A ship used to gather salvage from destroyed ships.",
    cost = {material=30,crew=10},
    fow = 0.5,
    crew = 5,
    size = 32,
    speed = 50,
    health = {max = 5,},
    material = 10,
    scrap_gather = 25,
    repair = false,
    actions = {"salvage","repair","collect"},
    collect = false,
  }
end
