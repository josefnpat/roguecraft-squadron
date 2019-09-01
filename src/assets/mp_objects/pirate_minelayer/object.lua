return function()
  local ship = require"assets.mp_objects.minelayer.object"()
  ship.type = "pirate_minelayer"
  ship.actions = {
    "build_pirate_mine",
  }
  return ship
end
