return function()
  local ship = require"assets.mp_objects.minelayer.object"()
  ship.type = "alien_minelayer"
  ship.actions = {
    "build_alien_mine",
  }
  return ship
end
