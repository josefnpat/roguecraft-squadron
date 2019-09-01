return function()
  local ship = require"assets.mp_objects.cargo.object"()
  ship.type = "pirate_cargo"
  return ship
end
