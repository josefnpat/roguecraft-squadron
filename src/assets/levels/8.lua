local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.warning'),vn_audio.adj.warning)
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.15'),vn_audio.com.line15)
  tvn:addFrame(nil,nil,libs.i18n('vn.tip.base'),libs.i18n('vn.tip.8'))
  return tvn
end

level.blackhole = 4
level.station = 16
level.asteroid = 16
level.scrap = nil
level.enemy = 64
level.jumpscrambler = 32
level.boss = 1

return level
