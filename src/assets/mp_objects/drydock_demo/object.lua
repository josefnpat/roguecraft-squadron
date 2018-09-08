return function()
  local ship = require"assets.mp_objects.drydock.object"()
  ship.type = "drydock_demo"
  ship.actions = {
    "build_salvager",
    "build_habitat",
    --"build_mining",
    --"build_refinery",
    --"build_cargo",
    "build_radar",
    --"build_command_demo",
    --"build_repair",
    -- "build_research",
  }
  return ship
end
