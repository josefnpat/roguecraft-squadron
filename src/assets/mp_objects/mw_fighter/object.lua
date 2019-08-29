return function()
  local ship = require"assets.mp_objects.fighter.object"()
  ship.type = "mw_fighter"
  ship.size = 16
  return ship
end
