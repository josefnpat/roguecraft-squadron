local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Warning: Hostiles detected.",vn_audio.adj.warning)
  --tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","We will be unable to leave this system until the threat has been neutralized.",vn_audio.adj.line9)
  tvn:addFrame(vn.com.default,nil,"Commander","Well, that’s just dandy. I guess I better use some of those materials I processed to make a [Battlestar] or two, and get rid of them.",vn_audio.com.line8)
  tvn:addFrame(nil,nil,"[TIP]","Objects with green chevrons are under your control. Objects with yellow chevrons are neutral. Objects with Red chevrons are hostile.")
  return tvn
end

level.blackhole = 1
level.station = 4
level.asteroid = 8
level.scrap = 32
level.enemy = 2
level.jumpscrambler = nil

return level
