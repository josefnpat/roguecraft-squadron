local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,"Adjutant","Warning: hostiles detected.")
  tvn:addFrame(vn.adj.default,"Commander","Are you going to say that every time we jump into a system?")
  tvn:addFrame(nil,"[TIP]","Your resources show you <amount>/<max> [d<change over time>]")
  return tvn
end

level.asteroid = difficulty.low_asteroid
level.enemy = difficulty.low_enemy

return level
