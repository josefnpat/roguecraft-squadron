local level = {}

level.id = "4"
level.next_level = "5"
level.victory = libs.levelshared.team_2_and_3_defeated
level.map = "random"
level.research_reward = 75

level.players_skel = {
  gen = libs.levelshared.gen.lovejam,
}

level.players_config_skel = {
  team = 1,
}

level.ai_players = {
  {
    config = {
      ai = 1, -- ID
      team = 2,
      diff = 3, -- difficulty
      race = 4, -- hybrid
    },
    gen = libs.levelshared.gen.alien,
  },
  {
    config = {
      ai = 2, -- ID
      team = 2,
      diff = 3, -- difficulty
      race = 4, -- hybrid
    },
    gen = libs.levelshared.gen.alien,
  },
  {
    config = {
      ai = 3, -- ID
      team = 2,
      diff = 1, -- difficulty
      race = 4, -- hybrid
    },
    gen = libs.levelshared.gen.none,
  },
}

level.intro = function(self)
  local tvn = libs.vn.new()
  local vn_data = require(self.dir.."/assets")
  local vn = vn_data.images
  local vn_audio = vn_data.audio
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.warning'),vn_audio.adj.warning)
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.10'),vn_audio.com.line10)
  --tvn:addFrame(nil,nil,libs.i18n('vn.tip.base'),libs.i18n('vn.tip.4'))
  return tvn
end

level.blackhole = 1
level.station = 8
level.asteroid = 12
level.scrap = 32
level.enemy = 12
level.jumpscrambler = 2

return level
