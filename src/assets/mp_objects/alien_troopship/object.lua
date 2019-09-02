return function()
  local ship = require"assets.mp_objects.troopship.object"()
  ship.type = "alien_troopship"
  ship.size = 32
  return ship
end
