return function()
  return {
    type = "jumpscrambler",
    display_name = "Jump Scrambler",
    info = "This platform prevents your fleet from jumping.",
    size = 32,
    rotate = (math.random(0,1)*2-1)/10,
    cost = {material=100,crew=10},
    crew = 10,
    health = {max=5},
    actions = {"salvage","repair"},
    jump_disable = true,
  }
end
