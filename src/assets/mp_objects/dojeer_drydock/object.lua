return function()
  local ship = require"assets.mp_objects.drydock.object"()
  ship.type = "dojeer_drydock"
  ship.actions = {
    "build_dojeer_salvager",
    "build_dojeer_habitat",
    "build_dojeer_mining",
    "build_dojeer_refinery",
    "build_dojeer_cargo",
    -- "build_radar",
    "build_dojeer_command",
    -- "build_repair",
    -- "build_research",
  }
  return ship
end
