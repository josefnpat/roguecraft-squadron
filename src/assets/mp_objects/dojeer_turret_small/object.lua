return function()
  local ship = require"assets.mp_objects.turret_small.object"()
  ship.type = "dojeer_turret_small"
  ship.shoot.type = "laser"
  return ship
end
