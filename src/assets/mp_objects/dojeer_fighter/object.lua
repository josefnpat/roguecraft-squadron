return function()
  local ship = require"assets.mp_objects.fighter.object"()
  ship.type = "dojeer_fighter"
  ship.shoot.type = "laser"
  return ship
end
