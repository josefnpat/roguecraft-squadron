return function()
  local ship = require"assets.mp_objects.advdrydock.object"()
  ship.type = "pirate_advdrydock"
  ship.actions = {
    "build_pirate_fighter",
    "build_pirate_combat",
    "build_pirate_artillery",
    "build_pirate_minelayer",
    "build_pirate_tank",
    "build_pirate_turret_tiny",
    "build_pirate_turret_small",
    "build_pirate_turret_large",
    -- "build_jump",
    "build_pirate_troopship",
    "build_pirate_capital",
  }
  return ship
end
