local level = {}

level.id = "9"
level.next_level = "epilogue"
level.victory = libs.levelshared.team_2_and_3_defeated
level.research_reward = 50

level.players_config_skel = {
  team = 1,
  gen = libs.levelshared.gen.campaign_grace,
}

level.ai_players = {
  {
    config = {
      ai = 1, -- ID
      team = 1,
      diff = 5, -- difficulty
      race = 1,
      gen = libs.levelshared.gen.campaign_miho,
    },
  },
  {
    config = {
      ai = 2, -- ID
      team = 2,
      diff = 5, -- difficulty
      race = 2,
      gen = libs.levelshared.gen.dojeer,
    },
  },
  {
    config = {
      ai = 3, -- ID
      team = 2,
      diff = 5, -- difficulty
      race = 2,
      gen = libs.levelshared.gen.dojeer,
    },
  },
  {
    config = {
      ai = 4, -- ID
      team = 2,
      diff = 5, -- difficulty
      race = 2,
      gen = libs.levelshared.gen.dojeer,
    },
  },
}

level.intro = function()
  return "Level 9 Prelude"
end

level.outro = function()
  return "Level 9 Complete"
end

return level
