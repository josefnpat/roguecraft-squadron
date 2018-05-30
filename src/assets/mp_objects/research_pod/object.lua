return function()
  return {
    type = "research_pod",
    size = 32,
    variation = math.random(1,100) == 1 and 1 or 0,
    rotate = (math.random(0,1)*2-1)/10,
    minimap = false,
    research = 1,
    pc = false,
  }
end
