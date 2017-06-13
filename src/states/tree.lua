local state = {}

function state:init()

  self.tree = {}

  self.tree_class = libs.tree.new()

  self.icon_bg = love.graphics.newImage("assets/hud/icon_bg.png")
  self.tree_bg = love.graphics.newImage("assets/hud/tree_bg.png")

  self.colors = {
    prereq_missing = {255,0,0},
    prereq_satisfied = {127,255,127},
    notmax = {0,255,0},
    max = {0,127,0},
    selected = {255,255,255},
    unselected = {127,127,127},
  }

  self.tree_class:loadData()
  self.tree = self.tree_class._data

  self._icon_cache = {}

end

function state:getOffset()
  return love.graphics.getWidth()/2,love.graphics.getHeight()/2
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

function state:draw()
  libs.stars:draw()
  libs.stars:drawPlanet()

  local cx,cy = self:getOffset()

  local old_line_width = love.graphics.getLineWidth()
  love.graphics.setLineWidth(8)

  for i,v in pairs(self.tree) do
    local found_child = false
    local children_string = "Children:\n"
    for _,child in pairs(v.children) do
      local target = self.tree[child.name]
      if target then
        love.graphics.line(
          v.x+cx,v.y+cy,
          target.x+cx,target.y+cy)
        children_string = children_string .. child.name .. "\n"
        found_child = true
      elseif child.name then
        self.tree[child.name] = nil
      end
    end
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

    love.graphics.printf(v.name,
      x - self.tree_bg:getWidth()/2,
      y - self.icon_bg:getHeight()/2-font:getHeight(),
      self.tree_bg:getWidth(),"center")

    love.graphics.printf("["..v.level.."/"..v.maxlevel.."]",
      x - self.tree_bg:getWidth()/2,
      y + self.icon_bg:getHeight()/2,
      self.tree_bg:getWidth(),"center")

    if debug_mode then
      love.graphics.print("x:"..v.x.." y:"..v.y,x,y-self.tree_bg:getHeight()/2)
    end

    love.graphics.setColor(255,255,255)
    dropshadowf("Spend your research points to continue.",0,32,love.graphics.getWidth(),"center")

    if self.window then
      love.graphics.setColor(0,0,0,127)
      love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
      love.graphics.setColor(255,255,255)
      self.window:draw()
    end

    love.graphics.setColor(255,255,255)
    love.graphics.setFont(fonts.menu)
    dropshadow("Research Points: "..settings:read("tree_points"),32,32)
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
      "c .. connect selected node\n"..
      "e .. edit selected node\n"..
      "r .. rename selected node interal\n"..
      "d .. delete node\n",32,32)

    if self.chooser then
      self.chooser:draw()
    end
  end

end

function state:getColorByNode(v)
  if v.level == v.maxlevel then
    return self.colors.max
  elseif settings:read("tree_points") >= v.cost then
    if v.level == 0 then
      return self.colors.prereq_satisfied
    else
      return self.colors.notmax
    end
  else
    return self.colors.prereq_missing
  end
end

function state:update(dt)
  if self.window then
    self.window:update(dt)
  end
  if settings:read("tree_points") <= 0 then
    libs.hump.gamestate.switch(states.mission)
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
  end
end

function state:mousepressed(x,y,b)
  if self.chooser or self.window then
  else
    local cx,cy = self:getOffset()

    if self.move then
      self.tree[self.move].x = x - cx
      self.tree[self.move].y = y - cy
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
  if not self.window and self.selected then
    self.window = libs.window.new{
      title=self.tree[self.selected].title or "Research",
      text=self.tree[self.selected].desc,
      color=self:getColorByNode(self.tree[self.selected]),
      image = self._icon_cache[self.selected],
      buttons = {
        {
          text=function()
            if self.tree[self.selected].level < self.tree[self.selected].maxlevel then
              if settings:read("tree_points") >= self.tree[self.selected].cost then
                return "RESEARCH ["..(self.tree[self.selected].cost).."]"
              else
                return "NOT ENOUGH RP ["..(self.tree[self.selected].cost).."]"
              end
            else
              return "RESEARCH [MAX]"
            end
          end,
          callback = function()
            if settings:read("tree_points") >= self.tree[self.selected].cost and
              self.tree[self.selected].level < self.tree[self.selected].maxlevel then
              self.tree[self.selected].level = self.tree[self.selected].level + 1
              settings:write("tree_points",settings:read("tree_points")-self.tree[self.selected].cost)
            end
            self.window = nil
            self.selected = nil
          end
        },
        {
          text="CANCEL",
          callback = function()
            self.window = nil
            self.selected = nil
          end
        }
      },
    }
    self.window.x = (love.graphics.getWidth()-self.window.w)/2
    self.window.y = (love.graphics.getHeight()-self.window.h)/2


  end
end

return state
