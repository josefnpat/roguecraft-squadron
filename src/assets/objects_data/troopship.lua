return function()
  return {
    type = "troopship",
    display_name = "Troopship",
    info = "A vessal used to take over neutral ships or damaged enemy ships.",
    cost = {material=50,crew=25},
    fow = 0.75,
    crew = 25,
    size = 32,
    speed = 150,
    health = {max = 15,},
    repair = false,
    takeover = 0.25,
    actions = {"salvage","repair"},
    build_time = 3,
  }
end
