local level = {}

level.id = "5"
level.next_level = "6"
level.victory = libs.levelshared.team_2_and_3_defeated

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
  {
    config = {
      ai = 2, -- ID
      team = 2,
      diff = 3, -- difficulty
    },
    gen = libs.levelshared.gen.alien,
  },
}

level.intro = function(self)
  local tvn = libs.vn.new()
  local vn_data = require(self.dir.."/assets")
  local vn = vn_data.images
  local vn_audio = vn_data.audio
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.warning'),vn_audio.adj.warning)
  --tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.11'),vn_audio.com.line11)
  --tvn:addFrame(nil,nil,libs.i18n('vn.tip.base'),libs.i18n('vn.tip.5'))
  return tvn
end

level.blackhole = 2
level.station = 8
level.asteroid = 16
level.scrap = 32
level.enemy = 18
level.jumpscrambler = 4

return level
