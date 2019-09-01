return function()
  local ship = require"assets.mp_objects.tank.object"()
  ship.type = "pirate_tank"
  ship.shoot.type = "laser"
  return ship
end
