local level = {}

level.id = "2"
level.next_level = "3"
level.victory = libs.levelshared.team_2_and_3_defeated

level.players_config_skel = {
  team = 1,
  gen = libs.levelshared.gen.campaign_ruby,
}

level.ai_players = {
  {
    config = {
      ai = 1, -- ID
      team = 1,
      diff = 2, -- difficulty
      race = 1,
      gen = libs.levelshared.gen.campaign_valentina,
    },
  },
  {
    config = {
      ai = 2, -- ID
      team = 2,
      diff = 2, -- difficulty
      race = 2,
      gen = libs.levelshared.gen.dojeer,
    },
  },
  {
    config = {
      ai = 3, -- ID
      team = 2,
      diff = 2, -- difficulty
      race = 2,
      gen = libs.levelshared.gen.dojeer,
    },
  },
  {
    config = {
      ai = 4, -- ID
      team = 2,
      diff = 1, -- difficulty
      race = 2,
      gen = libs.levelshared.gen.none,
    },
  },
}

level.intro = function()
  return "Level 2 Prelude"
end

level.outro = function()
  return "Level 2 Complete"
end

return level
