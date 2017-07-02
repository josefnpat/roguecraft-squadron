local level = {}

level.intro = function(self)
  local tvn = libs.vn.new()
  --tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.0'))--,vn_audio[1][1])
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.1'),vn_audio.adj.line1)
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.1'),vn_audio.com.line1)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.2'),vn_audio.adj.line2)
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.2'),vn_audio.com.line2)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.3'),vn_audio.adj.line3)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.4'),vn_audio.adj.line4)
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.3'),vn_audio.com.line3)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.5'),vn_audio.adj.line5)
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.4'),vn_audio.com.line4)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.correct'),vn_audio.adj.correct)
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.5'),vn_audio.com.line5)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.correct'),vn_audio.adj.correct)
  tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.6'),vn_audio.com.line6)
  tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.6'),vn_audio.adj.line6)
  --tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.7'),vn_audio.adj.line7)
  --tvn:addFrame(vn.com.default,nil,libs.i18n('vn.com.base'),libs.i18n('vn.com.7'),vn_audio.com.line7)
  --tvn:addFrame(vn.adj.default,vn.adj.overlay,libs.i18n('vn.adj.base'),libs.i18n('vn.adj.8'),vn_audio.adj.line8)
  tvn:addFrame(nil,nil,libs.i18n('vn.tip.base'),libs.i18n('vn.tip.1'))
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
    objtext = libs.i18n('tutorial.obj.1'),
    helptext = libs.i18n('tutorial.help.1'),
    title = libs.i18n('tutorial.title.base'),
    completetext = libs.i18n('tutorial.continue'),
  }

  t:add{
    objtext = libs.i18n('tutorial.obj.2'),
    helptext = libs.i18n('tutorial.help.2'),
    complete = function() return libs.tutorial.wait.select_single_object("command") end,
    helpguides = {"object_command","action_lmb"},
  }

  t:add{
    objtext = libs.i18n('tutorial.obj.3'),
    helptext = libs.i18n('tutorial.help.3'),
    complete = function()
      local ship = libs.tutorial.wait.select_single_object("command")
      return ship and (ship.target or ship.target_object)
    end,
    helpguides = {"object_command","action_rmb"},
  }

  t:add{
    objimage = love.graphics.newImage("assets/tutorial/map.png"),
    objtext = libs.i18n('tutorial.obj.4'),
    helptext = libs.i18n('tutorial.help.4'),
    complete = libs.tutorial.wait.camera_moved,
  }

  --[[
  t:add{
    objtext = libs.i18n('tutorial.obj.5'),
    helptext = libs.i18n('tutorial.help.5'),
    complete = function()
      local ship = libs.tutorial.wait.select_single_object("command")
      return ship and ship.repair
    end,
    helpguides = {"object_command","action_repair"},
  }
  --]]

  t:add{
    objtext = libs.i18n('tutorial.obj.6'),
    helptext = libs.i18n('tutorial.help.6'),
    complete = function()
      return libs.tutorial.wait.select_single_object("scrap") or libs.tutorial.wait.object_is_target("scrap")
    end,
    helpguides = {"object_scrap"},
  }

  t:add{
    objtext = libs.i18n('tutorial.obj.7'),
    helptext = libs.i18n('tutorial.help.7'),
    complete = function() return libs.tutorial.wait.object_exists("salvager") end,
    helpguides = {"object_command","object_salvager"},
  }

  t:add{
    objtext = libs.i18n('tutorial.obj.8'),
    helptext = libs.i18n('tutorial.help.8'),
    complete = function()
      local ship = libs.tutorial.wait.select_single_object("salvager")
      return ship and ship.target_object and ship.target_object.type == "scrap"
    end,
    helpguides = {"object_salvager","object_scrap"},
  }

  t:add{
    objtext = libs.i18n('tutorial.obj.9'),
    helptext = libs.i18n('tutorial.help.9'),
    complete = function()
      return libs.tutorial.wait.object_exists("fighter")
    end,
    helpguides = {"object_command","object_fighter"},
  }

  t:add{
    objtext = libs.i18n('tutorial.obj.10'),
    helptext = libs.i18n('tutorial.help.10'),
    objguides = {"object_jump","action_jump"},
    completetext = "DONE",
  }

  return t
end

return level
