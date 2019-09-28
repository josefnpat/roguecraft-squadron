local level = {}

level.id = "8"
level.name = "Chapter 8:\nTo The Death"
level.next_level = "9"
level.victory = libs.levelshared.team_2_and_3_defeated
level.research_reward = 50

level.players_skel = {
  gen = libs.levelshared.gen.campaign_ruby,
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
      diff = 5, -- difficulty
      race = 2,
    },
    gen = libs.levelshared.gen.dojeer,
  },
  {
    config = {
      ai = 3, -- ID
      team = 2,
      diff = 5, -- difficulty
      race = 2,
    },
    gen = libs.levelshared.gen.dojeer,
  },
  {
    config = {
      ai = 4, -- ID
      team = 2,
      diff = 1, -- difficulty
      race = 2,
    },
    gen = libs.levelshared.gen.none,
  },
}

level.intro = function()
  return "Level 8 Prelude"
end

level.outro = function()
  return "Level 8 Complete"
end

return level
