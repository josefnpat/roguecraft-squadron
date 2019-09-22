local level = {}

level.id = "4"
level.name = "Chapter 4:\nInevitable"
level.next_level = "5"
level.victory = libs.levelshared.team_2_and_3_defeated
level.research_reward = 50

level.players_config_skel = {
  team = 1,
  gen = libs.levelshared.gen.campaign_ruby,
}

level.ai_players = {
  {
    config = {
      ai = 1, -- ID
      team = 1,
      diff = 3, -- difficulty
      race = 1,
      gen = libs.levelshared.gen.campaign_valentina,
    },
  },
  {
    config = {
      ai = 2, -- ID
      team = 2,
      diff = 3, -- difficulty
      race = 2,
      gen = libs.levelshared.gen.dojeer,
    },
  },
  {
    config = {
      ai = 3, -- ID
      team = 2,
      diff = 3, -- difficulty
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
  return "Level 4 Prelude"
end

level.outro = function()
  return "Level 4 Complete"
end

return level
