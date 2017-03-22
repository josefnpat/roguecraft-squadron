local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Warning: hostiles detected.",vn_audio.adj.warning)
  tvn:addFrame(vn.com.default,nil,"Commander","We’re only one jump away from home! We’ve got to make it! Everyone is counting on us!",vn_audio.com.line15)
  tvn:addFrame(nil,nil,"[TIP]","Losing is fun! Either way, it keeps you busy.")
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
