return function()
  local ship = require"assets.mp_objects.habitat.object"()
  ship.type = "pirate_habitat"
  return ship
end