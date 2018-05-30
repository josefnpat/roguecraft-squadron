return function()
  return {
    type = "blackhole",
    gravity_well = {
      range = 256,
      damage = 25, -- was 10
    },
    size = 128,
    rotate = (math.random(0,1)*2-1),
    pc = false,
    minimap = false,
  }
end
