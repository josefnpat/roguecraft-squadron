local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,"Adjutant","Adjutant: Warning: hostiles detected. We will be unable to leave this system until the threat has been neutralized.")
  tvn:addFrame(vn.adj.default,"Commander","Well, that’s just dandy. I guess I better use some of those materials I processed to make a [Battlestar] or two, and get rid of them.")
  tvn:addFrame(bil,"[TIP]","Objects with green chevrons are under your control. Objects with yellow chevrons are neutral. Objects with Red chevrons are hostile.")
  return tvn
end

level.enemy = difficulty.tutorial_enemy

return level
