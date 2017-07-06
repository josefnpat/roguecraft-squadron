local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.warning'),vn_audio.adj.warning)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.9'),vn_audio.adj.line9)
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.8'),vn_audio.com.line8)
  tvn:addFrame(nil,nil,libs.i18n('vn.tip.base'),libs.i18n('vn.tip.2'))
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
    objtext = libs.i18n('tutorial.obj.11'),
    helptext = libs.i18n('tutorial.help.11'),
    objguides = {"object_enemy_fighter"},--,"object_fighter"},
    helpguides = {"object_command","object_fighter"},--,"object_combat","object_artillery","object_tank"},
    complete = function()
      return
        #libs.tutorial.wait.objects_find("enemy_fighter") == 0 and
        #libs.tutorial.wait.objects_find("enemy_combat") == 0 and
        #libs.tutorial.wait.objects_find("enemy_artillery") == 0 and
        #libs.tutorial.wait.objects_find("enemy_tank") == 0 and
        #libs.tutorial.wait.objects_find("enemy_miniboss") == 0
    end,
  }

  --[[
  t:add{
    objtext = libs.i18n('tutorial.obj.12'),
    helptext = libs.i18n('tutorial.help.12'),
    helpguides = {"object_command","object_drydock","object_mining","object_asteroid"},
    complete = function()
      local ship = libs.tutorial.wait.select_single_object("mining")
      return ship and ship.target_object and ship.target_object.type == "asteroid"
    end,
  }

  t:add{
    objtext = libs.i18n('tutorial.obj.13'),
    helptext = libs.i18n('tutorial.help.13'),
    helpguides = {"object_command","object_drydock","object_refinery","action_refine"},
    complete = function()
      local ship = libs.tutorial.wait.select_single_object("refinery")
      return ship and ship.refine
    end,
  }
  --]]

  t:add{
    objtext = libs.i18n('tutorial.obj.14'),
    helptext = libs.i18n('tutorial.help.14'),
    helpguides = {"object_enemy_jumpscrambler"},
    complete = function()
      return #libs.tutorial.wait.objects_find("enemy_jumpscrambler") == 0
    end,
  }

  t:add{
    objtext = libs.i18n('tutorial.obj.15'),
    helptext = libs.i18n('tutorial.help.15'),
    helpguides = {"action_cta","action_collect"},
    title = libs.i18n('tutorial.title.complete'),
    completetext = libs.i18n('tutorial.done'),
  }

  return t
end

return level
