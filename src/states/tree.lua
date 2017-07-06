local state = {}

function state:init()

  self.tree = {}

  --TODO: NOT HACK
  g_tree = g_tree or libs.tree.new()
  self.tree_class = g_tree

  self.icon_bg = love.graphics.newImage("assets/hud/icon_bg.png")
  self.tree_bg = love.graphics.newImage("assets/hud/tree_bg.png")

  self.colors = {
    prereq_missing = {191,0,0},
    cant_afford = {255,0,0},
    max = {0,255,0},
    not_researched = {255,255,255},
    partially_researched = {127,255,127},
    selected = {255,255,255},
    unselected = {255,255,255},
  }

  self.tree_class:loadData()
  self.tree = self.tree_class._data

  self._x,self._y = 0,0

  self._icon_cache = {}

  self.clamp = {xmin=0,ymin=0,xmax=0,ymax=0}

  for i,v in pairs(self.tree) do
    self.clamp.xmax = v.x > self.clamp.xmax and v.x or self.clamp.xmax
    self.clamp.xmin = v.x < self.clamp.xmin and v.x or self.clamp.xmin
    self.clamp.ymax = v.y > self.clamp.ymax and v.y or self.clamp.ymax
    self.clamp.ymin = v.y < self.clamp.ymin and v.y or self.clamp.ymin
  end
  -- lol don't ask ffs inverted camera i hate you
  self.clamp.ymin,self.clamp.ymax = -self.clamp.ymax,-self.clamp.ymin

end

function state:getOffset()
  if self._x > self.clamp.xmax then self._x = self.clamp.xmax end
  if self._x < self.clamp.xmin then self._x = self.clamp.xmin end
  if self._y > self.clamp.ymax then self._y = self.clamp.ymax end
  if self._y < self.clamp.ymin then self._y = self.clamp.ymin end
  return
    love.graphics.getWidth()/2+self._x,
    love.graphics.getHeight()/2+self._y
end

function state:textinput(t)
  if self._ignore_textinput_single then
    self._ignore_textinput_single = nil
  else
    if self.chooser then
      self.chooser:textinput(t)
    end
  end
end

function state:enter()
  self.tree_class:loadGame()
end

function state:draw()
  libs.stars:draw()
  libs.stars:drawPlanet()

  local cx,cy = self:getOffset()

  local old_line_width = love.graphics.getLineWidth()
  love.graphics.setLineWidth(8)

  for i,v in pairs(self.tree) do
    local found_child = false -- debug
    local children_string = "Children:\n" -- debug
    for _,child in pairs(v.children) do
      local target = self.tree[child.name]
      if target then
        love.graphics.setColor(self:getColorByNode(target))
        love.graphics.line(
          v.x+cx,v.y+cy,
          target.x+cx,target.y+cy)
        children_string = children_string .. child.name .. "\n" --debug
        found_child = true -- debug
      elseif child.name then
        self.tree[child.name] = nil
      end
    end
    love.graphics.setColor(255,255,255)
    if found_child and debug_mode then
      love.graphics.print(children_string,v.x+cx,v.y+cy+self.tree_bg:getHeight()/2)
    end
  end

  love.graphics.setLineWidth(old_line_width)

  for i,v in pairs(self.tree) do
    local x,y = v.x+cx,v.y+cy
    if i == self.move then
      x,y = love.mouse.getPosition()
    end
    if i == self.selected then
      love.graphics.setColor(self.colors.selected)
    else
      love.graphics.setColor(self.colors.unselected)
    end
    love.graphics.draw(self.tree_bg,x-self.tree_bg:getWidth()/2,y-self.tree_bg:getHeight()/2)

    love.graphics.setColor(self:getColorByNode(v))
    love.graphics.draw(self.icon_bg,x-self.icon_bg:getWidth()/2,y-self.icon_bg:getHeight()/2)

    if not self._icon_cache[v.name] then
      self._icon_cache[v.name] = love.graphics.newImage(table.concat(v.asset,"/"))
      self._icon_cache[v.name]:setFilter("nearest","nearest")
    end
    local icon = self._icon_cache[v.name]

    love.graphics.draw(icon,x-icon:getWidth()/2,y-icon:getWidth()/2)

    local font = love.graphics.getFont()

    dropshadowf(v.title,
      x - self.tree_bg:getWidth()/2,
      y - self.icon_bg:getHeight()/2-font:getHeight(),
      self.tree_bg:getWidth(),"center")

    dropshadowf(libs.i18n('tree.node.info',{
        cost = v.cost,
        level = self.tree_class:getLevelData(v.name),
        level_max = v.maxlevel,
      }),
      x - self.tree_bg:getWidth()/2,
      y + self.icon_bg:getHeight()/2,
      self.tree_bg:getWidth(),
      "center"
    )

    love.graphics.setColor(255,255,255)
    if debug_mode then
      love.graphics.print("x:"..v.x.." y:"..v.y.." cost:"..v.cost,
        x-self.tree_bg:getWidth()/2,
        y-self.tree_bg:getHeight()/2)
    end
    dropshadowf(libs.i18n('tree.info'),0,icon:getHeight(),love.graphics.getWidth(),"center")

    if self.window then
      love.graphics.setColor(0,0,0,127)
      love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
      love.graphics.setColor(255,255,255)
      self.window:draw()
    end

    love.graphics.setColor(255,255,255)
    love.graphics.setFont(fonts.menu)
    dropshadow(libs.i18n('tree.research_points',{
      research_points=settings:read("tree_points"),
    }),icon:getHeight(),icon:getHeight())
    love.graphics.setFont(fonts.default)

  end

  if debug_mode then
    love.graphics.print(
      "s .. save\n"..
      "l .. load\n"..
      "n .. new node\n"..
      "m .. move selected node\n"..
      "↑→↓← .. nudge selected node\n"..
      "[lshift+] +|- .. change [max]level\n"..
      "page[up|down] .. change cost\n"..
      "c .. connect selected node\n"..
      "e .. edit selected node\n"..
      "r .. rename selected node interal\n"..
      "t .. change title\n"..
      "d .. delete node\n",32,32)

    if self.chooser then
      self.chooser:draw()
    end
  end

end

function state:getColorByNode(v)
  if not self:havePrereq(v) then
    return self.colors.prereq_missing
  end
  if settings:read("tree_points") < v.cost then
    return self.colors.cant_afford
  end
  if self.tree_class:getLevelData(v.name) == v.maxlevel then
    return self.colors.max
  end
  if self.tree_class:getLevelData(v.name)  == 0 then
    return self.colors.not_researched
  end
  return self.colors.partially_researched
end

function state:havePrereq(node)
  for i,v in pairs(self.tree) do
    for j,w in pairs(v.children) do
      if node.name == w.name then
        return self.tree_class:getLevelData(v.name) > 0
      end
    end
  end
  return true
end

function state:update(dt)

  if self.window then
    self.window:update(dt)
  else
    if love.keyboard.isDown("left") then
      self._x = self._x + 500*dt
    end
    if love.keyboard.isDown("right") then
      self._x = self._x - 500*dt
    end
    if love.keyboard.isDown("up") then
      self._y = self._y + 500*dt
    end
    if love.keyboard.isDown("down") then
      self._y = self._y - 500*dt
    end

  end
end

function state:keypressed(key)

  if debug_mode then
    -- NO YOU'RE A SCREWY EDITOR
    if key == "escape" then
      self.chooser = nil
      self.window = nil
    end
    if self.chooser then
      self.chooser:keypressed(key)
    else
      if self.tree[self.selected] then
        if key == "up" then
          self.tree[self.selected].y = self.tree[self.selected].y - 1
        elseif key == "down" then
          self.tree[self.selected].y = self.tree[self.selected].y + 1
        elseif key == "left" then
          self.tree[self.selected].x = self.tree[self.selected].x - 1
        elseif key == "right" then
          self.tree[self.selected].x = self.tree[self.selected].x + 1
        elseif key == "r" then
          self._ignore_textinput_single = true
          self.chooser = libs.stringchooser.new{
            prompt = "internal:",
            string = self.tree[self.selected].name,
            callback = function(string)
              self.chooser = nil
              local obj = self.tree[self.selected]
              self.tree[self.selected] = nil
              obj.name = string
              self.tree[string] = obj
            end,
          }
        elseif key == "t" then
          self._ignore_textinput_single = true
          self.chooser = libs.stringchooser.new{
            prompt = "title:",
            string = self.tree[self.selected].title,
            callback = function(string)
              self.chooser = nil
              self.tree[self.selected].title = string
            end,
          }
        end
        if key == "pageup" then
          self.tree[self.selected].cost = self.tree[self.selected].cost + 1
        elseif key == "pagedown" then
          self.tree[self.selected].cost = self.tree[self.selected].cost - 1
        end
        if love.keyboard.isDown("lshift") then
          if key == "-" then
            self.tree[self.selected].maxlevel = self.tree[self.selected].maxlevel - 1
          elseif key == "=" then
            self.tree[self.selected].maxlevel = self.tree[self.selected].maxlevel + 1
          end
        else
          if key == "-" then
            self.tree[self.selected].level = self.tree[self.selected].level - 1
          elseif key == "=" then
            self.tree[self.selected].level = self.tree[self.selected].level + 1
          end
        end
      end
      if key == "s" then
        self.tree_class:saveData()
      elseif key == "l" then
        self.tree_class:loadData()
        self.tree = self.tree_class._data
      elseif key == "n" then
        self.chooser = libs.assetchooser.new{
          prompt = "icon:",
          callback = function(asset)
            --code
            local asset_tab = asset:split("/")
            self.chooser = libs.stringchooser.new{
              string = asset_tab[#asset_tab]:sub(1,-5) or "",
              prompt = "internal:",
              callback = function(name)
                --code
                self.chooser = nil
                local node = {
                  name = name,
                  x = 0,
                  y = 0,
                  children = {
                  },
                  cost = 0,
                  level = 0,
                  maxlevel = 1,
                  asset = asset_tab,
                }
                self.tree[name] = node
                self.selected = name
              end
            }
          end,
        }
        self._ignore_textinput_single = true
      elseif key == "m" then
        self.move = self.selected
      elseif key == "d" then
        self.tree[self.selected] = nil
      elseif key == "c" then
        if self.to_connect then
          if self.to_connect == self.selected then
            self.tree[self.selected].children = {}
          else
            table.insert(self.tree[self.to_connect].children,{name=self.selected})
            self.selected = nil
            self.to_connect = nil
          end
        else
          self.to_connect = self.selected
          self.selected = nil
        end
      elseif key == "escape" then
        self.move = nil
        self.selected = nil
      end
    end
  else
    if key == "escape" or key == "return" then
      if self.window then
        self.window = nil
      else
        self.tree_class:saveGame()
        libs.hump.gamestate.switch(previousState)
      end
    end
  end
end

function state:mousepressed(x,y,b)
  if self.chooser or self.window then
  else
    local cx,cy = self:getOffset()

    if self.move then
      self.tree[self.move].x = math.floor((x - cx + 16)/32)*32
      self.tree[self.move].y = math.floor((y - cy + 16)/32)*32
      self.move = nil
    else
      local found = false
      for i,v in pairs(self.tree) do
        local ix,iy = v.x + cx,v.y + cy
        if x > ix - self.tree_bg:getWidth()/2 and x < ix + self.tree_bg:getWidth()/2 and
           y > iy - self.tree_bg:getHeight()/2 and y < iy + self.tree_bg:getHeight()/2 then
          self.selected = i
          found = true
          break
        end
      end
      if not found then
        self.selected = nil
      end
    end
  end
  if not self.window and self.selected and not debug_mode then
    self.window = libs.window.new{
      w=32*20,
      title=self.tree[self.selected].title or "Research",
      text=self.tree[self.selected].desc,
      color=self:getColorByNode(self.tree[self.selected]),
      buttons = {
        {
          text=function()
            if self.tree_class:getLevelData(self.selected) < self.tree[self.selected].maxlevel then
              if not self:havePrereq(self.tree[self.selected]) then
                return libs.i18n('tree.node.status.missing_prereq',{
                  cost = self.tree[self.selected].cost
                })
              elseif settings:read("tree_points") >= self.tree[self.selected].cost then
                return libs.i18n('tree.node.status.ready',{
                  cost = self.tree[self.selected].cost
                })
              else
                return libs.i18n('tree.node.status.need_points',{
                  cost = self.tree[self.selected].cost
                })
              end
            else
              return libs.i18n('tree.node.status.max')
            end
          end,
          callback = function()
            local node = self.tree[self.selected]

            if settings:read("tree_points") >= self.tree[self.selected].cost and
              self.tree_class:getLevelData(self.selected) < self.tree[self.selected].maxlevel and
              self:havePrereq(self.tree[self.selected]) then
              self.tree_class:incrementLevel(self.selected)
              settings:write("tree_points",settings:read("tree_points")-self.tree[self.selected].cost)
            end
            self.window = nil
            self.selected = nil
          end
        },
        {
          text=libs.i18n('tree.node.cancel'),
          callback = function()
            self.window = nil
            self.selected = nil
          end
        }
      },
    }

    self.window.x = (love.graphics.getWidth()-self.window.w)/2
    self.window.y = (love.graphics.getHeight()-self.window.h)/2

    self.window:addGuide(self.tree[self.selected].info,self._icon_cache[self.selected])

  end
end

return state
