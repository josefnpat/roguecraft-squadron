local vnjson = {}

function vnjson.new(init)
  init = init or {}
  local self = {}

  self.stop = vnjson.stop
  self.play = vnjson.play
  self.next = vnjson.next
  self.halt = vnjson.halt
  self.active = vnjson.active
  self.getNode = vnjson.getNode
  self.getNodeLoc = vnjson.getNodeLoc
  self.drawImage = init.drawImage or vnjson.drawImage
  self.drawName = init.drawName or vnjson.drawName
  self.drawText = init.drawText or vnjson.drawText
  self.draw = vnjson.draw
  self.update = vnjson.update

  self._dir = init.dir or ""
  self._assets = init.assets or self._dir
  if self._dir then
    local raw = love.filesystem.read(self._dir.."/data.json")
    self._data = libs.json.decode(raw)
  else
    print("warning: Could not read `"..init.json.."`")
    self._data = {}
  end

  self._lang_fallback = "en" or init.lang_fallback
  self._lang = init.lang or self._lang_fallback

  -- images tend to be reused, so we will cache them
  self._images = {}
  for _,nodes in pairs(self._data) do
    if not self._images[nodes.image] then
      self._images[nodes.image] = love.graphics.newImage(self._assets.."/"..nodes.image)
    end
  end

  self._padding = init.padding or 16
  self._text_height = init.text_height or 128
  self._text_width = init.text_width or 920
  self._current = 0
  self._aux = {}
  self:next()

  return self
end

function vnjson:stop()
  local node = self._data[self._current]
  if self._aux.audio then
    self._aux.audio:stop()
  end
  self._aux = {}
end

function vnjson:play()
  local node = self:getNode()
  if node then
    local node_loc = self:getNodeLoc(node)
    if node_loc.audio then
      self._aux.audio = love.audio.newSource(self._assets.."/"..node_loc.audio,"stream")
    end
    self._aux.audio:setVolume(settings:read("voiceover_vol",1))
    self._aux.audio:play()
  end
end

function vnjson:next()
  self:stop()
  self._current = self._current + 1
  self:play()
end

function vnjson:halt()
  self:stop()
  self._current = -1
end

function vnjson:active()
  return self:getNode() ~= nil
end

function vnjson:getNode()
  return self._data[self._current]
end

function vnjson:getNodeLoc(node)
  return node[self._lang] or node[self._lang_fallback] or {}
end

function vnjson:drawImage(image)
  love.graphics.draw(
    image,
    love.graphics.getWidth()/2,
    love.graphics.getHeight()-image:getHeight(),
    0,1,1,
    image:getWidth()/2)
end

function vnjson:drawName(name)
  love.graphics.setFont(fonts.vn_name)
  local width = fonts.vn_name:getWidth(name)+self._padding*2
  local height = fonts.vn_name:getHeight()
  local x = (love.graphics.getWidth()-self._text_width)/2
  local y = love.graphics.getHeight()-self._text_height-self._padding-height
  --tooltipbg(x,y,width,height)
  dropshadowf(name,x,y,width,"center")
end

function vnjson:drawText(text)
  local x = (love.graphics.getWidth()-self._text_width)/2
  local y = love.graphics.getHeight()-self._text_height-self._padding
  tooltipbg(x,y,self._text_width,self._text_height)
  love.graphics.setFont(fonts.vn_text)
  dropshadowf(
    text,
    x+self._padding,
    y+self._padding,
    self._text_width-self._padding*2,
    "center")
end

function vnjson:draw()
  local node = self:getNode()
  if node then
    local orig_font = love.graphics.getFont()
    love.graphics.setColor(0,0,0,191)
    love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
    love.graphics.setColor(255,255,255)
    if node.image then
      self:drawImage(self._images[node.image])
    end
    local node_loc = self:getNodeLoc(node)
    if node_loc.name then
      self:drawName(node_loc.name)
    end
    if node_loc.text then
      self:drawText(node_loc.text)
    end
    love.graphics.setFont(fonts.vn_info)
    love.graphics.setColor(127,127,127)
    dropshadowf(
      "[Press escape at any time to skip this cutscene.]",
      0,
      love.graphics.getHeight()-fonts.vn_info:getHeight(),
      love.graphics.getWidth(),
      "center")
    love.graphics.setColor(255,255,255)
    love.graphics.setFont(orig_font)
  end
end

function vnjson:update(dt)
  local node = self:getNode()
  if node then
    if self._aux.audio then
      if not self._aux.audio:isPlaying() then
        self:next()
      end
    end
  end
end

return vnjson
