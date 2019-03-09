local mpserverlist = {}

function mpserverlist.load(loadAssets)
  if loadAssets then
    mpserverlist.icons = {
      refresh=love.graphics.newImage("assets/hud/refresh.png"),
      prev=love.graphics.newImage("assets/hud/arrow_prev.png"),
      next=love.graphics.newImage("assets/hud/arrow_next.png"),
    }
  end
end

local http = require"socket.http"
local url = "http://50.116.63.25/roguecraftsquadron.com/serverlist.php"

-- https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99
local char_to_hex = function(c)
  return string.format("%%%02X", string.byte(c))
end
local function urlencode(url)
  if url == nil then
    return
  end
  url = url:gsub("\n", "\r\n")
  url = url:gsub("([^%w ])", char_to_hex)
  url = url:gsub(" ", "+")
  return url
end
local hex_to_char = function(x)
  return string.char(tonumber(x, 16))
end
local urldecode = function(url)
  if url == nil then
    return
  end
  url = url:gsub("+", " ")
  url = url:gsub("%%(%x%x)", hex_to_char)
  return url
end

function mpserverlist.sendRequest(input)
  -- print("Sending serverlist request ...")
  local payload = "?i="..urlencode(libs.json.encode(input))
  local r,e = http.request(url..payload)
  return e == 200 and libs.json.decode(r) or nil
end

function mpserverlist.sendPublicUpdate(started,players)
  local input = {
    name=settings:read("user_name"),
    port=settings:read("server_port"),
    owner=game_randomstring,
    started=started or false,
    players=players or -1,
  }
  mpserverlist.sendRequest(input)
end


function mpserverlist.new(init)
  init = init or {}
  local self = libs.mpwindow.new()

  self.getLastPage = mpserverlist.getLastPage
  self.changeCurrent = mpserverlist.changeCurrent
  self.foreachpage = mpserverlist.foreachpage
  self.requestRefresh = mpserverlist.requestRefresh
  self.draw = mpserverlist.draw
  self.update = mpserverlist.update

  self._page_offset = 1
  self._page_count = 10

  self._width = 480
  self._height = 640-109+40-4 -- Magic!

  self._refreshButton = libs.button.new{
    width = 32,
    height = self._button_height,
    onClick = function()
      self:requestRefresh()
    end,
    icon=mpserverlist.icons.refresh,
  }

  self._prevButton = libs.button.new{
    height=self._buttonHeight,
    width = self._button_height,
    height = self._button_height,
    onClick = function()
      self:changeCurrent(-1)
    end,
    icon=mpserverlist.icons.prev,
  }

  self._nextButton = libs.button.new{
    height=self._buttonHeight,
    width = self._button_height,
    height = self._button_height,
    onClick = function()
      self:changeCurrent(1)
    end,
    icon=mpserverlist.icons.next,
  }

  self._connectButtons = {}
  self:requestRefresh()

  return self
end

function mpserverlist:getLastPage()
  return math.max(1,math.floor((#self._connectButtons-1)/self._page_count+1))
end

function mpserverlist:changeCurrent(val)
  self._page_offset = self._page_offset + val
  self._prevButton:setDisabled(self._page_offset == 1)
  self._nextButton:setDisabled(self._page_offset == self:getLastPage())
end

function mpserverlist:foreachpage(pageitems,f)
  local start = (self._page_offset-1)*self._page_count + 1
  local real_i = 0
  for i = start,start+self._page_count-1 do
    real_i = real_i + 1
    if pageitems[i] then
      f(real_i,pageitems[i])
    end
  end
end

function mpserverlist:requestRefresh()
  local r,e = http.request(url)
  self._data = e == 200 and libs.json.decode(r) or nil
  self._connectButtons = {}
  for _,connection in pairs(self._data.list) do
    if connection.started == false then
      table.insert(self._connectButtons,libs.button.new{
        text=connection.name.." ["..connection.players .."/"..libs.net.max_players.."]",
        onClick=function()
          states.menu:connectToServer(connection.ip,connection.port)
        end,
      })
    end
  end
  self._page_offset = 1
  self:changeCurrent(0)
end

function mpserverlist:draw()

  if not self:isActive() then return end
  local window,content = self:windowdraw(dt)

  local padding = self._padding

  self._refreshButton:setX(window.x+padding)
  self._refreshButton:setY(window.y+self:getHeight()-self._refreshButton:getHeight()-padding)
  self._refreshButton:draw()

  self._prevButton:setX(window.x+padding*2+self._refreshButton:getWidth())
  self._prevButton:setY(window.y+self:getHeight()-self._prevButton:getHeight()-padding)
  self._prevButton:draw()

  self._nextButton:setX(window.x+self._refreshButton:getWidth()+self._nextButton:getWidth()+padding*3)
  self._nextButton:setY(window.y+self:getHeight()-self._nextButton:getHeight()-padding)
  self._nextButton:draw()

  self:setWindowTitle("Public Server List ("..self._page_offset.."/"..self:getLastPage()..")")

  if self._data then
    if #self._data.list > 0 then
      local button_height = 40+4
      self:foreachpage(self._connectButtons,function(button_index,button)
        button:setX(content.x)
        button:setY(content.y+(button_index-1)*button_height)
        button:setWidth(content.width)
        button:draw()
      end)
    else
      love.graphics.printf("No public servers.", content.x, content.y+content.height/2, content.width, "center")
    end

  else
    love.graphics.printf("Loading server list ... ", content.x, content.y+content.height/2, content.width, "center")
  end

end

function mpserverlist:update(dt)
  if self:isActive() then
    self:windowupdate(dt)
    self._prevButton:update(dt)
    self._nextButton:update(dt)
    self._refreshButton:update(dt)
    self:foreachpage(self._connectButtons,function(i,button)
      button:update(dt)
    end)
  end
end

return mpserverlist
