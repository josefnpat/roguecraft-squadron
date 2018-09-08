return function()
  local ship = require"assets.mp_objects.advdrydock.object"()
  ship.type = "advdrydock_demo"
  ship.actions = {
    "build_fighter",
    --"build_combat",
    "build_artillery",
    --"build_minelayer",
    "build_tank",
    "build_turret_small",
    --"build_turret_large",
    -- "build_jump",
    --"build_troopship",
  }
  return ship
end
