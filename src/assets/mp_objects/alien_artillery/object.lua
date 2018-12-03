return function()
  local ship = require"assets.mp_objects.artillery.object"()
  ship.type = "alien_artillery"
  ship.shoot.type = "laser"
  return ship
end
