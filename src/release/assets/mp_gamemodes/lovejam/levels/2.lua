local level = {}

level.id = "2"
level.next_level = "3"
level.victory = libs.levelshared.team_2_and_3_defeated
level.map = "random"
level.research_reward = 75

level.players_config_skel = {
  team = 1,
  gen = libs.levelshared.gen.lovejam,
}

level.ai_players = {
  {
    config = {
      ai = 1, -- ID
      team = 2,
      diff = 2, -- difficulty
      race = 4, -- hybrid
      gen = libs.levelshared.gen.alien,
    },
  },
  {
    config = {
      ai = 2, -- ID
      team = 2,
      diff = 1, -- difficulty
      race = 4, -- hybrid
      gen = libs.levelshared.gen.none,
    },
  },
  {
    config = {
      ai = 3, -- ID
      team = 2,
      diff = 1, -- difficulty
      race = 4, -- hybrid
      gen = libs.levelshared.gen.none,
    },
  },
}

level._disable_intro = function(self)
  local tvn = libs.vn.new()
  local vn_data = require(self.dir.."/assets")
  local vn = vn_data.images
  local vn_audio = vn_data.audio
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.warning'),vn_audio.adj.warning)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.9'),vn_audio.adj.line9)
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.8'),vn_audio.com.line8)
  --tvn:addFrame(nil,nil,libs.i18n('vn.tip.base'),libs.i18n('vn.tip.2'))
  return tvn
end

level.blackhole = 1
level.station = 4
level.asteroid = 8
level.scrap = 32
level.enemy = 2
level.jumpscrambler = 1

return level
