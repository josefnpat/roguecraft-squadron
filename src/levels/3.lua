local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Warning: hostiles detected.")
  tvn:addFrame(vn.com.default,nil,"Commander","Looks like they’re catching on. I’m glad there are some more [Asteroids] in this system to take advantage of.")
  tvn:addFrame(nil,nil,"[TIP]","Every ship has a [Salvage] and [Repair] action.")
  return tvn
end

level.asteroid = difficulty.medium_asteroid
level.enemy = difficulty.low_enemy

return level
