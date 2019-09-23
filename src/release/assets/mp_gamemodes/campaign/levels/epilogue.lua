local level = {}

level.id = "epilogue"
level.name = "Epilogue"
level.victory = libs.levelshared.instant_victory
level.instant_victory = true

level.players_skel = {
  gen = libs.levelshared.gen.campaign_valentina,
}

level.players_config_skel = {
  team = 1,
}

level.ai_players = {
  {
    config = {
      ai = 1, -- ID
      team = 2,
      diff = 1, -- difficulty
      race = 1,
    },
    gen = libs.levelshared.gen.none,
  },
  {
    config = {
      ai = 2, -- ID
      team = 2,
      diff = 1, -- difficulty
      race = 1,
    },
    gen = libs.levelshared.gen.none,
  },
  {
    config = {
      ai = 3, -- ID
      team = 2,
      diff = 1, -- difficulty
      race = 1,
    },
    gen = libs.levelshared.gen.none,
  },
  {
    config = {
      ai = 4, -- ID
      team = 2,
      diff = 1, -- difficulty
      race = 1,
    },
    gen = libs.levelshared.gen.none,
  },
}

level.intro = function()
  return "Epilogue"
end

return level
