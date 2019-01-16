return function()
  local ship = require"assets.mp_objects.scout.object"()
  ship.type = "dojeer_scout"
  ship.shoot.type = "laser"
  return ship
end
