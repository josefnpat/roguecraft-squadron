return function()
  return {
    type = "mining",
    cost = {material=75,crew=10},
    fow = 0.5,
    crew = 10,
    size = 32,
    speed = 75,
    health = {max = 10,},
    ore = 250,
    ore_gather = 25,
    repair = false,
    actions = {"salvage","repair","collect","upgrade_mining"},
    collect = false,
    build_time = 5,
  }
end
