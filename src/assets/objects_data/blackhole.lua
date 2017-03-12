return function()
  return {
    type = "blackhole",
    display_name = "Black Hole",
    info = "A region of spacetime exhibiting such strong gravitational effects that nothing can escape from inside it.",
    gravity_well = {
      range = 256,
      damage = 10,
    },
    size = 128,
    rotate = (math.random(0,1)*2-1),
  }
end
