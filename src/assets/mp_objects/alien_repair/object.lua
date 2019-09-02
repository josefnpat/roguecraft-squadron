return function()
  local ship = require"assets.mp_objects.repair.object"()
  ship.type = "alien_repair"
  return ship
end
