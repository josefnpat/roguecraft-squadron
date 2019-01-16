return function()
  local ship = require"assets.mp_objects.artillery.object"()
  ship.type = "dojeer_artillery"
  ship.shoot.type = "laser"
  ship.size = 64
  return ship
end
