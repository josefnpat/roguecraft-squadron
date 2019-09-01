return function()
  local ship = require"assets.mp_objects.scout.object"()
  ship.type = "pirate_scout"
  ship.shoot.type = "laser"
  return ship
end
