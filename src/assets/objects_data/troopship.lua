return function()
  return {
    type = "troopship",
    display_name = "Troopship",
    info = "A vessal used to take over abandoned ships",
    cost = {material=50,crew=25},
    crew = 25,
    size = 32,
    speed = 150,
    health = {max = 25,},
    repair = false,
    actions = {"salvage","repair"}
  }
end
