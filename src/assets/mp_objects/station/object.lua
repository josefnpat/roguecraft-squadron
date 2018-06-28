local names = {
  "Armistice Station",
  "Babylon 5",
  "Deep Space Nine",
  "Elysium",
  "Empok Nor",
  "ISPV 7",
  "Midway Station",
  "Oberon",
  "Ragnar Anchorage",
  "Starbase 47 \"Vanguard\"",
  "Ticonderoga, Fleet Battlestation",
  "Endurance",
}

return function()
  return {
    type = "station",
    names = names,
    size = 64,
    crew_supply = math.random(75,150),
    rotate = (math.random(0,1)*2-1)/10,
    pc = false,
  }
end
