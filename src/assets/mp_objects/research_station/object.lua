return function()
  return {
    type = "research_station",
    size = 32,
    research_supply = math.random(1,2),
    rotate = (math.random(0,1)*2-1)/10,
    pc = false,
  }
end
