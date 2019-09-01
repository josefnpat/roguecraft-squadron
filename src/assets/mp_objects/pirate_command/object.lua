return function()
  local ship = require"assets.mp_objects.command.object"()
  ship.type = "pirate_command"
  ship.actions = {
    "build_pirate_scout",
    "build_pirate_turret_tiny",
    "build_pirate_salvager",
    "build_pirate_habitat",
    "build_pirate_drydock",
    "build_pirate_advdrydock",
  }
  return ship
end
