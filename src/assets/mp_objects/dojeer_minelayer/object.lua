return function()
  local ship = require"assets.mp_objects.minelayer.object"()
  ship.type = "dojeer_minelayer"
  ship.actions = {
    "build_dojeer_mine",
  }
  return ship
end
