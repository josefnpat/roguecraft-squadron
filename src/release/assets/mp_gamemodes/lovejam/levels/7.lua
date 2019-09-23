-- THIS LEVEL IS SKIPPED UNTIL ECON MISSION TYPE WORKS

local level = {}

level.id = "7"
level.next_level = "8"
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
      diff = 4, -- difficulty
      race = 4, -- hybrid
    },
    gen = libs.levelshared.gen.alien,
  },
  {
    config = {
      ai = 2, -- ID
      team = 2,
      diff = 4, -- difficulty
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
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.13'),vn_audio.com.line13)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.incorrect'),vn_audio.adj.incorrect)
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.14'),vn_audio.com.line14)
  --tvn:addFrame(nil,nil,libs.i18n('vn.tip.base'),libs.i18n('vn.tip.7'))
  return tvn
end

level.blackhole = nil
level.station = 16
level.asteroid = 32
level.scrap = nil
level.enemy = nil
level.jumpscrambler = nil

return level
