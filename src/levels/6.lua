local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Warning: hostiles detected.",vn_audio.adj.warning)
  tvn:addFrame(vn.com.default,nil,"Commander","This is not good.")
  tvn:addFrame(nil,nil,"[TIP]","Hold left-alt to view all the health bars.")
  return tvn
end

level.asteroid = difficulty.high_asteroid
level.enemy = difficulty.high_enemy

return level
