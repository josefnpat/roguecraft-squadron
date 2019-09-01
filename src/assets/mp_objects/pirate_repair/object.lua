return function()
  local ship = require"assets.mp_objects.repair.object"()
  ship.type = "pirate_repair"
  return ship
end
