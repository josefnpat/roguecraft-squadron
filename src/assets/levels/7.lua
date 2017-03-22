local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.com.default,nil,"Commander","Warning: hostiles detected...",vn_audio.com.line13)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","That is incorrect.",vn_audio.adj.incorrect)
  tvn:addFrame(vn.com.default,nil,"Commander","Woah, no enemies? That’s new ... better stockpile while I can!",vn_audio.com.line14)
  tvn:addFrame(nil,nil,"[TIP]","Press left-ctrl + <number> to assign a control group. Use <number> to select that control group.")
  return tvn
end

level.blackhole = nil
level.station = 16
level.asteroid = 32
level.scrap = nil
level.enemy = nil
level.jumpscrambler = nil

return level
