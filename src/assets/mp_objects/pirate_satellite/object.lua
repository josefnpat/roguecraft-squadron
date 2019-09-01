return function()
  local ship = require"assets.mp_objects.satellite.object"()
  ship.type = "pirate_satellite"
  return ship
end
