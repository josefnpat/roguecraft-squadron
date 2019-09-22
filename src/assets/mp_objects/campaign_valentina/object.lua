return function()
  local ship = require"assets.mp_objects.command.object"()
  ship.type = "campaign_valentina"
  ship.actions = {
    "build_scout",
    "build_turret_tiny",
    "build_salvager",
    "build_habitat",
    "build_drydock_campaign",
    "build_advdrydock",
  }
  ship.research = 999
  ship.research_generate = 0
  return ship
end
