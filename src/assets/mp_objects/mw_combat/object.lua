return function()
  local ship = require"assets.mp_objects.combat.object"()
  ship.type = "mw_combat"
  ship.size = 32
  return ship
end
