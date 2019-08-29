return function()
  return {
    type = "debug",
    cost = {material=1000,crew=100},
    points = 0,
    fow = 8,
    crew = 100,
    size = 64,
    speed = 300,
    health = {max = 75,},
    material = 1600,
    crew_generate = 100,
    material_generate = 100,
    ore_generate = 100,
    research_generate = 100,
    research=100,
    shoot = {
      type = "laser",
      reload = 2.5,
      damage = 20,
      speed = 200,
      range = 600,
      aggression = 400,
    },
    actions = {
      "build_command",
      "build_alien_command",
      "build_dojeer_command",
    },
    build_time = 60,
  }
end
