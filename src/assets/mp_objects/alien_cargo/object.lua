return function()
  local ship = require"assets.mp_objects.cargo.object"()
  ship.type = "alien_cargo"
  return ship
end
