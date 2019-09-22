return function()
  local ship = require"assets.mp_objects.drydock.object"()
  ship.type = "drydock_campaign"
  ship. actions = {
    "build_salvager",
    "build_habitat",
    "build_mining",
    "build_refinery",
    "build_cargo",
    "build_radar",
    --"build_command",
    "build_repair",
    --"build_research",
  }
  return ship
end
