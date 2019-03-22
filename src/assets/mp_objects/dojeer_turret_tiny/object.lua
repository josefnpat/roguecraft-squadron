return function()
  local ship = require"assets.mp_objects.turret_tiny.object"()
  ship.type = "dojeer_turret_tiny"
  ship.shoot.type = "laser"
  return ship
end
