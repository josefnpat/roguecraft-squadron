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

  self.menu:add(
    function()
      return "Everything is "..(libs.objectrenderer.pizza and "pizza" or "fine")
    end,
    function()
      libs.objectrenderer.pizza = not libs.objectrenderer.pizza
    end
  )

  self.menu.palettes = {"default","dark_yellow","light_yellow","green","greyscale","stark_bw","pocket"}
  self.menu:add(
    function()
      return "I am using a "..(GLOBAL_SHADER and "DMG-01" or "computer")
    end,
    function()
      if GLOBAL_SHADER then
        GLOBAL_SHADER,GLOBAL_SHADER_OBJ = nil,nil
      else
        self.menu.palette_index = (self.menu.palette_index or 0) + 1
        if self.menu.palette_index > #self.menu.palettes then
          self.menu.palette_index = 1
        end
        GLOBAL_SHADER = function()
          GLOBAL_SHADER_OBJ = libs.moonshine(libs.moonshine.effects.dmg)
          GLOBAL_SHADER_OBJ.dmg.palette = self.menu.palettes[self.menu.palette_index]
        end
        GLOBAL_SHADER()
      end

    end
  )

  self.menu:add(
    function()
      return "ObjectRenderer Shader [".. (settings:read("object_shaders") and "Enabled" or "Disabled").."]"
    end,
    function()
      settings:write("object_shaders",not settings:read("object_shaders"))
    end
  )

  self.menu:add("Dynamic Music Manager",function()
    states.menu.music.title:stop()
    libs.hump.gamestate.switch(states.dynamicmusic)
  end)

  self.menu:add(
    function()
      return "Enable all Game Modes ["..(libs.mpconnect.enable_all_modes and "Enabled" or "Disabled").."]"
    end,
    function()
      libs.mpconnect.enable_all_modes = not libs.mpconnect.enable_all_modes
    end
  )

  self.menu:add(
    function()
      return "Enable slow camera ["..(libs.camera_edge.slow_camera and "Enabled" or "Disabled").."]"
    end,
    function()
      libs.camera_edge.slow_camera = not libs.camera_edge.slow_camera
    end
  )

  self.menu:add("Back",function()
    libs.hump.gamestate.switch(states.menu)
  end)

end

function state:update(dt)
  self.menu:update(dt)
end

function state:draw()
  libs.stars:draw()
  libs.stars:drawPlanet()
  self.menu:draw()
end

return state
