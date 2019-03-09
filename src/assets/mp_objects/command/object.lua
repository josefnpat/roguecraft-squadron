return function()
  return {
    type = "command",
    class = libs.net.classTypes.construction,
    cost = {material=1000,crew=100},
    points = 25,
    fow = 0.5,
    crew = 100,
    research = 100,
    research_generate = 1,
    size = 64,
    speed = 50,
    health = {max = 300,},
    material = 600,
    construction_command = true,
    default_level = 1,
    actions = {
      "build_scout",
      "build_salvager",
      "build_habitat",
      "build_drydock",
      "build_advdrydock",
    },
    build_time = 60,
  }
end
