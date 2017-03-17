local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Warning: hostiles detected.",vn_audio.adj.warning)
  tvn:addFrame(vn.com.default,nil,"Commander","This is not good.",vn_audio.com.line12)
  tvn:addFrame(nil,nil,"[TIP]","Hold left-alt to view all the health bars.")
  return tvn
end

level.blackhole = 2
level.station = 8
level.asteroid = 24
level.scrap = 32
level.enemy = 24
level.jumpscrambler = 8

return level
