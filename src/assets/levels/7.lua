local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.13'),vn_audio.com.line13)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.incorrect'),vn_audio.adj.incorrect)
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.14'),vn_audio.com.line14)
  tvn:addFrame(nil,nil,libs.i18n('vn.tip.base'),libs.i18n('vn.tip.7'))
  return tvn
end

level.blackhole = nil
level.station = 16
level.asteroid = 32
level.scrap = nil
level.enemy = nil
level.jumpscrambler = nil

return level
