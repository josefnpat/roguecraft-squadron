return function()
  local ship = require"assets.mp_objects.tank.object"()
  ship.type = "dojeer_tank"
  ship.shoot.type = "laser"
  return ship
end
