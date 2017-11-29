return function()
  return {
    type = "cloud",
    size = 128,
    variation = math.random(0,2),
    rotate = (math.random(0,1)*2-1)/10,
    pc = false,
    minimap = false,
    slow = 0.125,
  }
end
