return function()
  local ship = require"assets.mp_objects.satellite.object"()
  ship.type = "alien_satellite"
  ship.size = 32
  return ship
end
