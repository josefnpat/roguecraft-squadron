return function()
  local ship = require"assets.mp_objects.scout.object"()
  ship.type = "mw_scout"
  ship.size = 8
  return ship
end
