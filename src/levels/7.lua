local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,"Commander","Warning: hostiles detected...")
  tvn:addFrame(vn.adj.default,"Commander","That is incorrect.")
  tvn:addFrame(vn.adj.default,"Commander","Woah, no enemies? That’s new … better stockpile while I can!")
  tvn:addFrame(nil,"[TIP]","Press left-ctrl + <number> to assign a control group. Use <number> to select that control group.")
  return tvn
end

level.asteroid = difficulty.high_asteroid

return level
