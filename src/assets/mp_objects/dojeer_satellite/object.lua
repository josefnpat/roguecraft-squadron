return function()
  local ship = require"assets.mp_objects.satellite.object"()
  ship.type = "dojeer_satellite"
  return ship
end
