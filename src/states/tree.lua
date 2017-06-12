local state = {}

function state:init()

  self.tree = {}

  self.tree_class = libs.tree.new()

  self.icon_bg = love.graphics.newImage("assets/hud/icon_bg.png")
  self.tree_bg = love.graphics.newImage("assets/hud/tree_bg.png")

  self.colors = {
    prereq_missing = {127,127,127},
    prereq_satisfied = {191,255,191},
    notmax = {0,255,0},
    max = {255,255,0},
    selected = {0,255,0},
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
    local children_string = "Children:\n"
    for _,child in pairs(v.children) do
      local target = self.tree[child.name]
      if target then
        love.graphics.line(
          v.x+cx,v.y+cy,
          target.x+cx,target.y+cy)
        children_string = children_string .. child.name .. "\n"
      elseif child.name then
        self.tree[child.name] = nil
      end
    end
    love.graphics.print(children_string,v.x+cx,v.y+cy+self.tree_bg:getHeight()/2)
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
    if true then
      love.graphics.setColor(self.colors.prereq_satisfied)
      --prereq_missing = {127,127,127},
      --prereq_satisfied = {191,255,191},
      --notmax = {0,255,0},
      --max = {255,255,0},
    else
      love.graphics.setColor(self.colors.notmax)
    end
    love.graphics.draw(self.icon_bg,x-self.icon_bg:getWidth()/2,y-self.icon_bg:getHeight()/2)

    if not self._icon_cache[v.name] then
      self._icon_cache[v.name] = love.graphics.newImage(table.concat(v.asset,"/"))
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

    love.graphics.print("x:"..v.x.." y:"..v.y,x,y-self.tree_bg:getHeight()/2)

    love.graphics.setColor(255,255,255)

  end

  love.graphics.print(
    "s .. save\n"..
    "l .. load\n"..
    "n .. new node\n"..
    "m .. move selected node\n"..
    "↑→↓← .. nudge selected node\n"..
    "[lshift+] +|- .. change [max]level\n"..
    "c .. connect selected node\n"..
    "e .. edit selected node\n"..
    "d .. delete node\n",32,32)

  if self.chooser then
    self.chooser:draw()
  end

end

function state:keypressed(key)
  -- NO YOU'RE A SCREWY EDITOR
  if key == "escape" then
    self.chooser = nil
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
          self.chooser = libs.stringchooser.new{
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
                asset = asset:split("/"),
              }
              self.tree[name] = node
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

function state:mousepressed(x,y,b)
  if self.chooser then
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
end

return state
