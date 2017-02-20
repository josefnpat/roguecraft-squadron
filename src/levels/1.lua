local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,"Adj","I'm six foot three, and maintain a very consistent panda bear shape.",vn_audio[1][1])
  return tvn
end

level.asteroid = 10

level.enemy = 0

return level
