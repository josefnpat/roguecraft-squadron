return function()
  local ship = require"assets.mp_objects.drydock.object"()
  ship.type = "pirate_drydock"
  ship.actions = {
    "build_pirate_salvager",
    "build_pirate_habitat",
    "build_pirate_mining",
    "build_pirate_refinery",
    "build_pirate_cargo",
    "build_pirate_radar",
    "build_pirate_command",
    "build_pirate_repair",
    "build_pirate_research",
  }
  return ship
end
