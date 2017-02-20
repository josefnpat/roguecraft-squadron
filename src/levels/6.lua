local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,"Adjutant","Warning: hostiles detected.")
  tvn:addFrame(vn.adj.default,"Commander","This is not good.")
  tvn:addFrame(nil,"[TIP]","Hold left-alt to view all the health bars.")
  return tvn
end

level.asteroid = difficulty.high_asteroid
level.enemy = difficulty.high_enemy

return level
