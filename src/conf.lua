settings = require"libs.settings".new()
settings:load()
settings:define("window_width",1280)
settings:define("window_height",720)
settings:define("window_fullscreen",false)
settings:define("window_fullscreen_type","desktop")
settings:define("window_display",1)
settings:define("window_vsync",false)
settings:define("window_msaa",2)
settings:define("camera_speed",1)
settings:define("bg_quality","high")
settings:define("voiceover_vol",0.3)
settings:define("sfx_vol",0.2)
settings:define("music_vol",0.3)
settings:define("fow_quality","img_canvas")
settings:define("remote_server_address","127.0.0.1")
settings:define("server_port","26000") --quake?
settings:define("server_public",true)
settings:define("server_name","")
settings:define("sensitive",false)
settings:define("user_name","Player")
settings:define("mouse_draw_mode","software")
settings:define("object_shaders",true)
settings:define("action_keys",{"z","x","c","v","b"})
settings:define("tutorial",true)

game_tagline = "Call to Arms"
game_name = "RogueCraft Squadron: "..game_tagline
git_hash,git_count = "missing git.lua",-1
game_singleplayer = false
game_randomstring = require("libs.randomstring")(32)
pcall( function() return require("git") end );

function love.conf(t)

  for _,v in pairs(arg) do

    if v == "--server" or v == "-s" then
      headless = true
    end

    local port
    if string.sub(v,0,2) == "-p" then
      port = string.sub(v,3)
    end
    if string.sub(v,0,6) == "--port" then
      port = string.sub(v,7)
    end
    if port and require("libs.acf.validator").is_port(port) then
      settings:write("server_port",port)
    end

    if v == "--private" then
      print("Private Server")
      settings:write("server_public",false)
    end
    if v == "--public" then
      print("Public Server")
      settings:write("server_public",true)
    end
    if string.sub(v,0,6) == "--name" then
      settings:write("user_name",string.sub(v,7))
    end

  end
  t.identity = "RogueCraftSquadron"

  if headless then
    t.window = false
    t.modules.graphics = false
    t.modules.window = false
    t.modules.audio = false
  else
    t.window.width = settings:read("window_width")
    t.window.height = settings:read("window_height")
    t.window.title = game_name
    t.window.resizable = true
    t.window.fullscreen = settings:read("window_fullscreen")
    t.window.fullscreentype = settings:read("window_fullscreen_type")
    t.window.window_display = settings:read("window_display")
    t.window.vsync = settings:read("window_vsync")
    t.window.msaa = settings:read("window_msaa")
    t.window.minwidth = 1280
    t.window.minheight = 720
  end

end
