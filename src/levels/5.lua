local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,"Adjutant","Warning: hostiles detected.")
  tvn:addFrame(vn.adj.default,"Commander","Damn, this is getting stickier and sticker.")
  tvn:addFrame(nil,"[TIP]","Click on a ship icon in the lower left to select a specific ship.")
  return tvn
end

level.asteroid = difficulty.medium_asteroid
level.enemy = difficulty.medium_enemy

return level
