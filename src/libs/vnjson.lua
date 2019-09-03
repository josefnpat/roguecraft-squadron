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
  self.drawTitle = init.drawTitle or vnjson.drawTitle
  self.draw = vnjson.draw
  self.update = vnjson.update
  self._dir = init.dir or ""
  self._assets = init.assets or self._dir

  if init.mdlevel then
    self._data = {}
    local md = libs.md2campaign.new{
      data=love.filesystem.read(self._dir.."/en.md"),
      assets=self._assets,
    }
    for _,mdlevel in pairs(init.mdlevel) do
      local level = md:getLevel(mdlevel)
      for _,line in pairs(level.lines) do
        if line.title then
          table.insert(self._data,{
            en = {
              title=line.title
            },
          })
        else
          local obj =
          table.insert(self._data,{
            en = {
              name = line.display_name,
              text = line.text,
              emote = line.emote,
              audio = line.audio_location,
            },
            image = line.image_location,
            hologram = line.hologram,
          })
        end
      end
    end
  else
    if self._dir then
      local raw = love.filesystem.read(self._dir.."/data.json")
      self._data = libs.json.decode(raw)
    else
      print("warning: Could not read `"..init.json.."`")
      self._data = {}
    end
  end
  self._lang_fallback = "en" or init.lang_fallback
  self._lang = init.lang or self._lang_fallback

  -- images tend to be reused, so we will cache them
  self._images = {}
  for _,nodes in pairs(self._data) do
    if nodes.image and not self._images[nodes.image] then
      local file = self._assets .. "/" .. nodes.image
      if love.filesystem.isFile(file) then
        self._images[nodes.image] = love.graphics.newImage(file)
      else
        print('not a file?',file)
      end
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
      local file = self._assets.."/"..node_loc.audio
      if love.filesystem.isFile(file) then
        self._aux.audio = love.audio.newSource(file,"stream")
        self._aux.audio:setVolume(settings:read("voiceover_vol",1))
        self._aux.audio:play()
      end
    end
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

function vnjson:drawImage(image,hologram)
  local x = (love.graphics.getWidth()-self._text_width)/2--love.graphics.getWidth()/2
  local y = love.graphics.getHeight()-image:getHeight()-self._padding
  local offset = 0--image:getWidth()/2)
  if hologram then
    libs.scanlib.draw(image,x,y,0,1,1,offset)
  else
    love.graphics.draw(image,x,y,0,1,1,offset)
  end
end

function vnjson:drawName(name)
  love.graphics.setFont(fonts.vn_name)
  local width = self._text_width--fonts.vn_name:getWidth(name)+self._padding*2
  local height = fonts.vn_name:getHeight()
  local x = (love.graphics.getWidth()-self._text_width)/2
  local y = love.graphics.getHeight()-self._text_height-self._padding-height
  --tooltipbg(x,y,width,height)
  dropshadowf(name,x,y,width,"center")
end

function vnjson:drawText(text,italic)
  local x = (love.graphics.getWidth()-self._text_width)/2
  local y = love.graphics.getHeight()-self._text_height-self._padding
  tooltipbg(x,y,self._text_width,self._text_height)
  love.graphics.setFont(italic and fonts.vn_italic or fonts.vn_text)
  dropshadowf(
    text,
    x+self._padding,
    y+self._padding,
    self._text_width-self._padding*2,
    "center")
end

function vnjson:drawTitle(text)
  love.graphics.setFont(fonts.vn_title)
  dropshadowf(
    text,
    0,
    (love.graphics.getHeight()-fonts.vn_title:getHeight())/2,
    love.graphics.getWidth(),
    "center")
end

function vnjson:draw()
  local node = self:getNode()
  if node then
    local orig_font = love.graphics.getFont()
    love.graphics.setColor(255,255,255)
    libs.backgroundlib.drawAlt()
    if node.image and self._images[node.image] then
      self:drawImage(self._images[node.image],node.hologram)
    end
    local node_loc = self:getNodeLoc(node)
    if node_loc.name then
      self:drawName(node_loc.name)
    end
    if node_loc.emote then
      self:drawText(node_loc.emote,true)
    elseif node_loc.text then
      self:drawText(node_loc.text)
    end
    if node_loc.title then
      self:drawTitle(node_loc.title)
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
    libs.scanlib.update(dt)
    if self._aux.audio then
      if not self._aux.audio:isPlaying() then
        self:next()
      end
    end
  end
end

return vnjson
