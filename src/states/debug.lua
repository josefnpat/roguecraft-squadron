local state = {}

function state:init()


  self.menu = libs.menu.new{title="[DEBUG]"}

  self.menu:add(
    function()
      return "Debug mode ["..(debug_mode and "Enabled" or "Disabled").."]"
    end,
    function()
      debug_mode = not debug_mode
    end
  )

  self.menu:add(
    function()
      return "Cheat mode ["..(cheat and "Enabled" or "Disabled").."]"
    end,
    function()
      cheat = not cheat
    end
  )

  self.menu:add(
    function()
      return "CWAL mode ["..(cheat_operation_cwal and "Enabled" or "Disabled").."]"
    end,
    function()
      cheat_operation_cwal = not cheat_operation_cwal
    end
  )

  self.menu:add(
    function()
      if love.filesystem.exists("demo.ogv") then
        return "Demo video [Delete]"
      else
        return "Demo video [Download]"
      end
    end,
    function()
      if love.filesystem.exists("demo.ogv") then
        love.filesystem.remove("demo.ogv")
      else
        local http = require"socket.http"
        local b, c, h = http.request("http://50.116.63.25/public/rcs/demo.ogv")
        print(c,h)
        love.filesystem.write("demo.ogv", b)
        b,c,h = nil,nil,nil
      end
    end
  )

  self.menu:add("Open save directory",
    function()
      love.system.openURL("file://"..love.filesystem.getSaveDirectory())
    end
  )

  self.menu:add("Back",function()
    libs.hump.gamestate.switch(states.menu)
  end)

  self.p = libs.matrixpanel.new{}

  for i,v in pairs(love.filesystem.getDirectoryItems("assets/actions/")) do
    self.p:addAction(love.graphics.newImage("assets/actions/"..v))
  end


end

function state:update(dt)
  self.p:update(dt)
  self.menu:update(dt)
end

function state:draw()
  libs.stars:draw()
  libs.stars:drawPlanet()
  self.menu:draw()
  self.p:draw()
end

return state
