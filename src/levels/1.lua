local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  --tvn:addFrame(vn.adj.default,"Adj","I'm six foot three, and maintain a very consistent panda bear shape.")--,vn_audio[1][1])
  tvn:addFrame(vn.adj.default,"Adjutant","Greetings commander. You have been awakened from stasis. The current date is September 21st, 2687.")
  tvn:addFrame(vn.adj.default,"Commander","What? I thought we were only going to be under for a few months. This wasn’t supposed to happen at all.")
  tvn:addFrame(vn.adj.default,"Adjutant","Invalid query. Try again?")
  tvn:addFrame(vn.adj.default,"Commander","What happened? Why have I been in stasis for over one hundred years?")
  tvn:addFrame(vn.adj.default,"Adjutant","Security protocol dictates that persons in statis should be kept in stasis until either the destination has been reached, or the ship reaches problematic thresholds.")
  tvn:addFrame(vn.adj.default,"Adjutant","Currently the food replimat is out of ice cream, putting the ship above protocol threshold seven. There are 1523 prior protocol issues, of which 1512 have been corrected.")
  tvn:addFrame(vn.adj.default,"Commander","Adjutant, why aren’t we at our destination?")
  tvn:addFrame(vn.adj.default,"Adjutant","Destination no longer exists.")
  tvn:addFrame(vn.adj.default,"Commander","Wasn’t our destination a planet?")
  tvn:addFrame(vn.adj.default,"Adjutant","Correct.")
  tvn:addFrame(vn.adj.default,"Commander","Well, that’s not good.")
  tvn:addFrame(vn.adj.default,"Adjutant","Correct.")
  tvn:addFrame(vn.adj.default,"Commander","How many jumps away is earth?")
  tvn:addFrame(vn.adj.default,"Adjutant","Using our isotope reserve, eight.")
  tvn:addFrame(vn.adj.default,"Adjutant","Warning: ship scanners detects hostile ships in the nearby systems.")
  tvn:addFrame(vn.adj.default,"Commander","Suggestions?")
  tvn:addFrame(vn.adj.default,"Adjutant","Acquire resources to prepare for battle. Select the [Drydock] and Construct a [Mining Rig] to mine ore from a nearby [Asteroid]. Construct a [Refinery] to process ore into materials.")
  tvn:addFrame(nil,"[TIP]","Select your ship with the left mouse button. Right mouse click to move selected ships. Use the icons in the upper right to perform actions. Move your mouse to the edge of the screen, or left click on the minimap to move your camera.")
  return tvn
end

level.asteroid = difficulty.tutorial_asteroid

return level
