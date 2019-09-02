return function()
  local ship = require"assets.mp_objects.capital.object"()
  ship.type = "alien_capital"
  ship.shoot.type = "laser"
  return ship
end
