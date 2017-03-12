return function()
  return {
    type = "mining",
    display_name = "Mining Rig",
    info = "An ore mining ship with some ore storage.",
    cost = {material=85,crew=10},
    fow = 0.5,
    crew = 10,
    size = 32,
    speed = 50,
    health = {max = 10,},
    ore = 25,
    ore_gather = 25,
    repair = false,
    actions = {"salvage","repair"}
  }

end
