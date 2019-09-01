return function()
  local ship = require"assets.mp_objects.turret_small.object"()
  ship.type = "pirate_turret_small"
  ship.shoot.type = "laser"
  return ship
end
