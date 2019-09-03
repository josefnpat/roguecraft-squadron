local level = {}

level.id = "epilogue"
level.victory = libs.levelshared.instant_victory

level.players_config_skel = {
  team = 1,
}

level.ai_players = {
  {
    config = {
      ai = 1, -- ID
      team = 2,
      diff = 1, -- difficulty
    },
    gen = libs.levelshared.gen.dojeer,
  },
}

level.intro = function()
  return "Epilogue"
end

return level
