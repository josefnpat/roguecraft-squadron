return function()
  return {
    type = "jump",
    cost = {material=200,crew=10},
    fow = 0.5,
    crew = 10,
    size = 32,
    speed = 75,
    health = {max = 10,},
    jump = 2,--used to be 1
    jump_process = true,
    build_time = 5,
    default_level = 1,
    actions = {
      "build_wormhole",
    }
  }
end
