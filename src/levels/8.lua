local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,"Adjutant","Warning: hostiles detected.")
  tvn:addFrame(vn.adj.default,"Commander","We’re only one jump away from home! We’ve got to make it! Everyone is counting on us!")
  tvn:addFrame(nil,"[TIP]","Losing is fun! Either way, it keeps you busy.")
  return tvn
end

level.asteroid = difficulty.high_asteroid
level.enemy = difficulty.high_enemy
level.boss = 1

return level
