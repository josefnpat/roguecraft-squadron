return function()
  local ship = require"assets.mp_objects.advdrydock.object"()
  ship.type = "alien_advdrydock"
  ship.actions = {
    "build_alien_fighter",
    "build_alien_combat",
    "build_alien_artillery",
    "build_alien_minelayer",
    "build_alien_tank",
    "build_alien_turret_tiny",
    "build_alien_turret_small",
    "build_alien_turret_large",
    -- "build_jump",
    "build_alien_troopship",
    "build_alien_capital",
  }
  return ship
end
