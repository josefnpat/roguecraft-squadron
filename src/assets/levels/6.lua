local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.warning'),vn_audio.adj.warning)
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.12'),vn_audio.com.line12)
  tvn:addFrame(nil,nil,libs.i18n('vn.tip.base'),libs.i18n('vn.tip.6'))
  return tvn
end

level.blackhole = 2
level.station = 8
level.asteroid = 24
level.scrap = 32
level.enemy = 24
level.jumpscrambler = 8

return level
