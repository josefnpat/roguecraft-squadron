local level = {}

level.id = "6"
level.next_level = "7"
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
      diff = 3, -- difficulty
    },
    gen = libs.levelshared.gen.alien,
  },
  -- {
  --   config = {
  --     ai = 2, -- ID
  --     team = 2,
  --     diff = 4, -- difficulty
  --   },
  --   gen = libs.levelshared.gen.alien,
  -- },
}

level.intro = function(self)
  local tvn = libs.vn.new()
  local vn_data = require(self.dir.."/assets")
  local vn = vn_data.images
  local vn_audio = vn_data.audio
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.warning'),vn_audio.adj.warning)
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.12'),vn_audio.com.line12)
  --tvn:addFrame(nil,nil,libs.i18n('vn.tip.base'),libs.i18n('vn.tip.6'))
  return tvn
end

level.blackhole = 2
level.station = 8
level.asteroid = 24
level.scrap = 32
level.enemy = 24
level.jumpscrambler = 8

return level
