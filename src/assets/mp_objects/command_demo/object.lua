return function()
  local ship = require"assets.mp_objects.command.object"()
  ship.type = "command_demo"
  ship.actions = {
    "build_scout",
    "build_salvager",
    "build_habitat",
    "build_drydock_demo",
    "build_advdrydock_demo",
  }
  return ship
end
