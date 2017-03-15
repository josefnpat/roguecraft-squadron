local names = {
  "Dinah","Alice","Grumpy Cat","Lil' Bub","Maru","Waffles","Morris",
}

return function()
  return {
    type = "cat",
    display_name = names[math.random(#names)],
    info = "???",
    size = 32,
    rotate = (math.random(0,1)*2-1)/10,
    minimap = false,
    actions = {"egg"},
  }
end
