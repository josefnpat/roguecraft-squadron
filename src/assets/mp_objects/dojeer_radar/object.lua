return function()
  local ship = require"assets.mp_objects.radar.object"()
  ship.type = "dojeer_radar"
  ship.actions = {
    "build_dojeer_satellite",
  }
  return ship
end
