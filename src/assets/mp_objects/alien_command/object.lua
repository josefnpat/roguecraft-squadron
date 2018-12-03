return function()
  local ship = require"assets.mp_objects.command.object"()
  ship.type = "alien_command"
  ship.actions = {
    "build_alien_scout",
    "build_alien_salvager",
    "build_alien_habitat",
    "build_alien_drydock",
    "build_alien_advdrydock",
  }
  return ship
end
