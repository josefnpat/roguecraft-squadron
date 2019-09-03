local level = {}

level.id = "1"
level.next_level = "2"
level.victory = libs.levelshared.team_2_and_3_defeated
level.map = "random"

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
    gen = libs.levelshared.gen.alien,
  },
  -- {
  --   config = {
  --     ai = 2, -- ID
  --     team = 2,
  --     diff = 1, -- difficulty
  --   },
  --   gen = libs.levelshared.gen.alien,
  -- },
}

level.blackhole = nil
level.station = 2
level.asteroid = nil
level.scrap = 32
level.enemy = nil
level.jumpscrambler = nil
level.jump = 0.9

return level
