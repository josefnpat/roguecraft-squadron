local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.warning'),vn_audio.adj.warning)
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.11'),vn_audio.com.line11)
  tvn:addFrame(nil,nil,libs.i18n('vn.tip.base'),libs.i18n('vn.tip.5'))
  return tvn
end

level.blackhole = 2
level.station = 8
level.asteroid = 16
level.scrap = 32
level.enemy = 18
level.jumpscrambler = 4

return level
