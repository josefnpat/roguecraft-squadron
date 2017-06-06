local state = {}

function state:init()

  self.tree = {}

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

end

function state:loadData()
  self.tree = {}
  for i,v in pairs(love.filesystem.getDirectoryItems("assets/tree/")) do
    local raw = love.filesystem.read("assets/tree/"..v.."/data.json")
    local data = libs.json.decode(raw)
    local icon_loc = "assets/"..table.concat(data.asset,"/")
    self.tree[v] = {
      data = data,
      f = require("assets/tree/"..v),
      icon = love.graphics.newImage(icon_loc),
    }
  end
end

function state:saveData()
  local data = {}
  for i,v in pairs(self.tree) do
    local raw = libs.json.encode(v.data)
    local dir = "src/assets/tree/"..i.."/"
    os.execute("mkdir -p "..dir)

    local f,err = io.open(dir.."data.json","w+")
    f:write(raw)
    f:close()

    local f,err = io.open(dir.."init.lua","w+")
    f:write("return function(level) end")
    f:close()
  end
end

function state:getOffset()
  return love.graphics.getWidth()/2,love.graphics.getHeight()/2
end

function state:update(dt)
end

function state:draw()
  libs.stars:draw()
  libs.stars:drawPlanet()

  local cx,cy = self:getOffset()

  local old_line_width = love.graphics.getLineWidth()
  love.graphics.setLineWidth(8)

  for i,v in pairs(self.tree) do
    for _,child in pairs(v.data.children) do
      local target = self.tree[child.name]
      assert(target,"Target does not exist: "..child.name)
      love.graphics.line(
        v.data.x+cx,v.data.y+cy,
        target.data.x+cx,target.data.y+cy)
    end
  end

  love.graphics.setLineWidth(old_line_width)

  for i,v in pairs(self.tree) do
    local x,y = v.data.x+cx,v.data.y+cy
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
    love.graphics.draw(v.icon,x-v.icon:getWidth()/2,y-v.icon:getWidth()/2)

    local font = love.graphics.getFont()

    love.graphics.printf(v.data.name,
      x - self.tree_bg:getWidth()/2,
      y - self.icon_bg:getHeight()/2-font:getHeight(),
      self.tree_bg:getWidth(),"center")

    love.graphics.printf("[0/"..v.data.maxlevel.."]",
      x - self.tree_bg:getWidth()/2,
      y + self.icon_bg:getHeight()/2,
      self.tree_bg:getWidth(),"center")

    love.graphics.setColor(255,255,255)

  end

  love.graphics.print(
    "m .. move selected item\n"..
    "s .. save\n"..
    "l .. load\n"..
    "d .. delete\n"..
    "c .. create connection\n"..
    "g .. generate\n",32,32)

end

function state:keypressed(key)
  -- NO YOU'RE A SCREWY EDITOR
  if true then --debug_mode then
    if key == "s" then
      self:saveData()
    elseif key == "l" then
      self:loadData()
    elseif key == "m" then
      self.move = self.selected
    elseif key == "d" then
      self.tree[self.selected] = nil
    elseif key == "c" then
      if self.to_connect then
        if self.to_connect == self.selected then
          self.tree[self.selected].data.children = {}
        else
          table.insert(self.tree[self.to_connect].data.children,{name=self.selected})
          self.selected = nil
          self.to_connect = nil
        end
      else
        self.to_connect = self.selected
        self.selected = nil
      end
    elseif key == "g" then
      local makeobj = function(name,dir,post)
        self.tree[name] = {}
        self.tree[name].data = {
          name = name,
          x = 0,
          y = 0,
          children = {},
          cost = 0,
          maxlevel = 1,
          asset = {dir,name..post},
        }
      end
      for i,v in pairs(love.filesystem.getDirectoryItems("assets/objects_data")) do
        local name = string.sub(v,1,-5)
        makeobj(name,"objects_icon","0.png")
      end
      for i,v in pairs(love.filesystem.getDirectoryItems("assets/actions")) do
        local name = string.sub(v,1,-5)
        makeobj(name,"actions",".png")
      end
      self:saveData()
      self:loadData()
    elseif key == "escape" then
      self.move = nil
      self.selected = nil
    end
  end
end

function state:mousepressed(x,y,b)
  local cx,cy = self:getOffset()

  if self.move then
    self.tree[self.move].data.x = x - cx
    self.tree[self.move].data.y = y - cy
    self.move = nil
  else
    local found = false
    for i,v in pairs(self.tree) do
      local ix,iy = v.data.x + cx,v.data.y + cy
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

return state
