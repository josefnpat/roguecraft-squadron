local stations = {
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
    display_name = stations[math.random(#stations)],
    info = "This station contains [Crew] which can be collected by a [Habitat].",
    size = 64,
    crew_supply = math.random(25,50),
  }
end
