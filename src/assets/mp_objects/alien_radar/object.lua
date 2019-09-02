return function()
  local ship = require"assets.mp_objects.radar.object"()
  ship.type = "alien_radar"
  ship.actions = {
    "build_alien_satellite",
  }
  return ship
end
