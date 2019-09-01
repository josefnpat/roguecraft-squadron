return function()
  local ship = require"assets.mp_objects.radar.object"()
  ship.type = "pirate_radar"
  ship.actions = {
    "build_pirate_satellite",
  }
  return ship
end
