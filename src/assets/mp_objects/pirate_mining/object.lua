return function()
  local ship = require"assets.mp_objects.mining.object"()
  ship.type = "pirate_mining"
  return ship
end
