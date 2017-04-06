local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","Warning: Hostiles detected.",vn_audio.adj.warning)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,"Adjutant","We will be unable to leave this system until the threat has been neutralized.",vn_audio.adj.line9)
  tvn:addFrame(vn.com.default,nil,"Commander","Well, that’s just dandy. I guess I better use some of those materials I processed to make a [Battlestar] or two, and get rid of them.",vn_audio.com.line8)
  tvn:addFrame(nil,nil,"[TIP]","Objects with green chevrons are under your control. Objects with yellow chevrons are neutral. Objects with Red chevrons are hostile.")
  return tvn
end

level.blackhole = 1
level.station = 4
level.asteroid = 8
level.scrap = 32
level.enemy = 2
level.jumpscrambler = 1

level.make_tutorial = function()
  local t = libs.tutorial.new()

  t:add{
    objtext = "We have detected enemy ships. We will need a small squad of Fighters to take them out.",
    helptext = "Build:\n* Fighters from your Command ship\n* Battlestars from they Drydock ship\n* Artillery and Armored Frontline Tanks from the Advanced Drydock",
    objguides = {"object_enemy_fighter","object_fighter"},
    helpguides = {"object_command","object_fighter","object_drydock","object_combat","object_advdrydock","object_artillery","object_tank"},
    skip = function()
      return
        #libs.tutorial.wait.objects_find("enemy_fighter") == 0 and
        #libs.tutorial.wait.objects_find("enemy_combat") == 0 and
        #libs.tutorial.wait.objects_find("enemy_artillery") == 0 and
        #libs.tutorial.wait.objects_find("enemy_tank") == 0 and
        #libs.tutorial.wait.objects_find("enemy_miniboss") == 0
    end
  }

  t:add{
    objtext = "We have detected asteroids in this system. We should use the Drydock to build some Mining Rigs to mine them.",
    helptext = "Select the command ship, and use the Build Drydock action if you haven't already. Select the Drydock, and use the Build Mining Rig action. Select the Mining Rig, and right mouse click on an Asteroid.",
    helpguides = {"object_command","object_drydock","object_mining","object_asteroid"},
    skip = function()
      local ship = libs.tutorial.wait.select_single_object("mining")
      return ship and ship.target_object and ship.target_object.type == "asteroid"
    end,
  }

  t:add{
    objtext = "We have some ore now, but we can't refine it without a Refinery. Build one and inform it to to convert Ore to Material. ",
    helptext = "Select the command ship, and use the Build Drydock action if you haven't already. Select the Drydock ship, and use the Build Refinery action. Select the Refinery ship, toggle the \"Refine Ore\" action.",
    helpguides = {"object_command","object_drydock","object_refinery","action_refine"},
    skip = function()
      local ship = libs.tutorial.wait.select_single_object("refinery")
      return ship and ship.refine
    end,
  }

  t:add{
    objtext = "The enemy has set up a Jump Scrambler in this system, which prevents us from jumping to the next system.",
    helptext = "Find and destroy all of the Jump Scramblers in the system.",
    helpguides = {"object_jumpscrambler"},
    skip = function()
      return #libs.tutorial.wait.objects_find("jumpscrambler") == 0
    end,
  }

  return t
end

return level
