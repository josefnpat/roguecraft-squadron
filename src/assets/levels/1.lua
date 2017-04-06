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
  --tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Warning: Ship scanners detect hostile ships in the nearby systems.",vn_audio.adj.line7)
  --tvn:addFrame(vn.com.default,nil,"Commander","Suggestions?",vn_audio.com.line7)
  --tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Acquire resources to prepare for battle. Select the [Drydock] and Construct a [Mining Rig] to mine ore from a nearby [Asteroid]. Construct a [Refinery] to process ore into materials.",vn_audio.adj.line8)
  --tvn:addFrame(nil,nil,"[TIP]","Select your ship with the left mouse button. Right mouse click to move selected ships. Use the icons in the upper right to perform actions. Move your mouse to the edge of the screen, use the arrow keys, or left click on the minimap to move your camera.")
  return tvn
end

level.blackhole = nil
level.station = 2
level.asteroid = nil
level.scrap = 32
level.enemy = nil
level.jumpscrambler = nil
level.jump = 0.9

level.make_tutorial = function()
  local t = libs.tutorial.new()

  t:add{
    objtext = "Greetings commander. I would like to test our basic systems. If you prefer not to, you may jump to the next system right away.",
    helptext = "If at any time you need help with an objective, you can get help here.",
    title = "Tutorial",
    completetext = "CONTINUE",
  }

  t:add{
    objtext = "During stasis, many systems have deteriorated. Please confirm that the command ship is still operational.",
    helptext = "Use the left mouse button to select the command ship",
    complete = function() return libs.tutorial.wait.select_single_object("command") end,
    helpguides = {"object_command"},
  }

  t:add{
    objtext = "Our information systems seem to be operational. Please confirm that our command ship is under your control.",
    helptext = "Use the right mouse button to move the ship anywhere.",
    complete = function()
      local ship = libs.tutorial.wait.select_single_object("command")
      return ship and (ship.target or ship.target_object)
    end,
    helpguides = {"object_command"},
  }
  t:add{
    objtext = "Our command ship has been damaged from our long travel. I suggest we tell the crew to repair it.",
    helptext = "Select the command ship, and toggle the \"Repair\" action.",
    complete = function()
      local ship = libs.tutorial.wait.select_single_object("command")
      return ship and ship.repair
    end,
    helpguides = {"object_command","action_repair"},
  }
  t:add{
    objtext = "In order to survive, we will need to collect resources. We should search this system for something to gather.",
    helptext = "Move around the map with by moving your mouse to the edge of the screen, or using WASD/Arrow Keys. Find scrap.",
    complete = function()
      return libs.tutorial.wait.select_single_object("scrap") or libs.tutorial.wait.object_is_target("scrap")
    end,
    helpguides = {"object_scrap"},
  }
  t:add{
    objtext = "Excellent. We found some scrap. We should use our command ship to build a salvager to gather it.",
    helptext = "Select the command ship, and use the \"Build Salvager\" action in the upper right corner.",
    complete = function() return libs.tutorial.wait.object_exists("salvager") end,
    helpguides = {"object_command","object_salvager"},
  }
  t:add{
    objtext = "Now that we have a salvager under our command, have it collect material from the scrap.",
    helptext = "Select the salvager, and have it target the scrap.",
    complete = function()
      local ship = libs.tutorial.wait.select_single_object("salvager")
      return ship and ship.target_object and ship.target_object.type == "scrap"
    end,
    helpguides = {"object_salvager","object_scrap"},
  }

  t:add{
    objtext = "Now that we have materials, we should build some ships to protect our squadron.",
    helptext = "Select the command ship, and build a Fighter.",
    complete = function()
      return libs.tutorial.wait.object_exists("fighter")
    end,
    helpguides = {"object_command","object_fighter"},
  }

  t:add{
    objtext = "When you believe our fleet is ready, inform the Jumpgate Generator to jump to the next system.",
    helptext = "Select the Jumpgate Generator, and use the Jump action.",
    helpguides = {"object_jump","action_jump"},
    objguides = {"action_jump"},
    completetext = "DONE",
  }
  return t
end

return level
