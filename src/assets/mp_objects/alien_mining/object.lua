return function()
  local ship = require"assets.mp_objects.mining.object"()
  ship.type = "alien_mining"
  return ship
end
