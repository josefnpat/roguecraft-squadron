return function()
  return {
    type = "habitat",
    cost = {material=100},
    fow = 0.5,
    crew = 5,
    crew_gather = 10,
    crew_generate = 2,
    size = 32,
    speed = 50,
    health = {max = 5,},
    repair = false,
    actions = {"salvage","repair","collect","upgrade_crew"},
    collect = false,
    build_time = 5,
  }
end
