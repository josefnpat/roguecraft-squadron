local names = {
  "Dinah","Alice","Grumpy Cat","Lil' Bub","Maru","Waffles","Morris","Bert",
}

return function()
  return {
    type = "cat",
    names = names,
    size = 32,
    rotate = (math.random(0,1)*2-1)/10,
    minimap = false,
    actions = {"egg"},
  }
end
