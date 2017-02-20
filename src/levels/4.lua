local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Warning: hostiles detected.",vn_audio.adj.warning)
  tvn:addFrame(vn.com.default,nil,"Commander","Are you going to say that every time we jump into a system?",vn_audio.com.line10)
  tvn:addFrame(nil,nil,"[TIP]","Your resources show you <amount>/<max> [d<change over time>]")
  return tvn
end

level.asteroid = difficulty.low_asteroid
level.enemy = difficulty.low_enemy

return level
