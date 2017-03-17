local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Warning: hostiles detected.",vn_audio.adj.warning)
  tvn:addFrame(vn.com.default,nil,"Commander","Damn, this is getting stickier and sticker.",vn_audio.com.line11)
  tvn:addFrame(nil,nil,"[TIP]","Click on a ship icon in the lower left to select a specific ship.")
  return tvn
end

level.blackhole = 2
level.station = 8
level.asteroid = 16
level.scrap = 32
level.enemy = 18
level.jumpscrambler = 4

return level
