return function()
  local ship = require"assets.mp_objects.command.object"()
  ship.type = "dojeer_command"
  ship.actions = {
    "build_dojeer_scout",
    "build_dojeer_salvager",
    "build_dojeer_habitat",
    "build_dojeer_drydock",
    "build_dojeer_advdrydock",
  }
  return ship
end
