return function()
  local ship = require"assets.mp_objects.command.object"()
  ship.type = "command_training"
  ship.research = 0
  ship.research_generate = 0
  ship.actions = {
    --"build_scout",
    "build_salvager",
    "build_habitat",
    -- "build_drydock",
    -- "build_advdrydock",
  }
  return ship
end
