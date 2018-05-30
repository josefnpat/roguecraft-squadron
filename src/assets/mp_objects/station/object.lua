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
    display_name = stations[math.random(#stations)] .. " — " .. "todo",-- libs.i18n('mission.object.station.name'),
    size = 64,
    crew_supply = math.random(25,50),
    rotate = (math.random(0,1)*2-1)/10,
    pc = false,
  }
end
