local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  --tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adj","I'm six foot three, and maintain a very consistent panda bear shape.")--,vn_audio[1][1])
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Greetings commander. You have been awakened from stasis. The current date is September 21st, 2687.",vn_audio.adj.line1)
  tvn:addFrame(vn.com.default,nil,"Commander","What? I thought we were only going to be under for a few months. This wasn’t supposed to happen at all.",vn_audio.com.line1)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Invalid query. Please try again.",vn_audio.adj.line2)
  tvn:addFrame(vn.com.default,nil,"Commander","What happened? Why have I been in stasis for over a hundred years?",vn_audio.com.line2)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Security protocol dictates that persons in statis should be kept in stasis until either the destination has been reached, or the ship reaches problematic thresholds.",vn_audio.adj.line3)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Currently the food replimat is out of ice cream, putting the ship above protocol threshold seven. There are 1523 prior protocol issues of which 1512 have been corrected.",vn_audio.adj.line4)
  tvn:addFrame(vn.com.default,nil,"Commander","Adjutant, why aren’t we at our destination?",vn_audio.com.line3)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Destination no longer exists.",vn_audio.adj.line5)
  tvn:addFrame(vn.com.default,nil,"Commander","Wasn’t our destination a planet?",vn_audio.com.line4)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Correct.",vn_audio.adj.correct)
  tvn:addFrame(vn.com.default,nil,"Commander","Well, that’s not good.",vn_audio.com.line5)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Correct.",vn_audio.adj.correct)
  tvn:addFrame(vn.com.default,nil,"Commander","How many jumps away is earth?",vn_audio.com.line6)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Using our isotope reserve, eight.",vn_audio.adj.line6)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Warning: Ship scanners detect hostile ships in the nearby systems.",vn_audio.adj.line7)
  tvn:addFrame(vn.com.default,nil,"Commander","Suggestions?",vn_audio.com.line7)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Acquire resources to prepare for battle. Select the [Drydock] and Construct a [Mining Rig] to mine ore from a nearby [Asteroid]. Construct a [Refinery] to process ore into materials.",vn_audio.adj.line8)
  tvn:addFrame(nil,nil,"[TIP]","Select your ship with the left mouse button. Right mouse click to move selected ships. Use the icons in the upper right to perform actions. Move your mouse to the edge of the screen, use the arrow keys, or left click on the minimap to move your camera.")
  return tvn
end

level.blackhole = nil
level.station = 2
level.asteroid = nil
level.scrap = 32
level.enemy = nil
level.jumpscrambler = nil
level.jump = 0.9

--[[
level.tutorial = libs.tutorial.new()

level.tutorial:add(
  "Confirm the navcom system functions by selecting your command ship.",
  function()
    local targets = {}
    for i,v in pairs(states.mission:getObjectIntersectionQuery{type="command"}) do
      local x,y = states.mission.camera:cameraCoords(v.position.x,v.position.y)
      table.insert(targets,{x=x,y=y})
    end
    return targets
  end,
  function()
    local selected = #states.mission:getObjectIntersectionQuery{selected=true}
    local command = #states.mission:getObjectIntersectionQuery{type="command",selected=true}
    return not (selected == 1 and command == 1)
  end)

level.tutorial:add(
  "Click somewhere in space to confirm that you have control of the vessal.",
  function() return {} end,
  function()
    local command = #states.mission:getObjectIntersectionQuery{type="command",target="not_nil"}
    return not (command == 1)
  end)
--]]

return level
