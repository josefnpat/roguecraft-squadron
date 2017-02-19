local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,"Adj",string.rep("YOLO ",20),nil)
  tvn:addFrame(vn.adj.default,"Adj",string.rep("CARPE DIEM ",20),nil)
  return tvn
end

return level
