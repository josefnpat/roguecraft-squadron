return function()
  local ship = require"assets.mp_objects.scout.object"()
  ship.type = "alien_scout"
  ship.shoot.type = "laser"
  return ship
end
