local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Warning: hostiles detected.",vn_audio.adj.warning)
  tvn:addFrame(vn.com.default,nil,"Commander","Looks like they’re catching on. I’m glad there are some more [Asteroids] in this system to take advantage of.",vn_audio.com.line9)
  tvn:addFrame(nil,nil,"[TIP]","Every ship has a [Salvage] and [Repair] action.")
  return tvn
end

level.blackhole = 1
level.station = 8
level.asteroid = 12
level.scrap = 16
level.enemy = 8
level.jumpscrambler = 1

return level
