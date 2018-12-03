return function()
  local ship = require"assets.mp_objects.combat.object"()
  ship.type = "alien_combat"
  ship.shoot.type = "laser"
  return ship
end
