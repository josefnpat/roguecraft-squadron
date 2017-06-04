local state = {}

function state:init()

  self.tree = {}

  for i,v in pairs(love.filesystem.getDirectoryItems("assets/tree/")) do
    local raw = love.filesystem.read("assets/tree/"..v.."/data.json")
    local data = libs.json.decode(raw)
    self.tree[v] = {
      data = data,
      f = require("assets/tree/"..v),
      icon = love.graphics.newImage("assets/objects_icon/"..data.icon..".png"),
    }
  end

  self.icon_bg = love.graphics.newImage("assets/icon_bg.png")
  self.tree_bg = love.graphics.newImage("assets/tree_bg.png")

  self.colors = {
    prereq_missing = {127,127,127},
    prereq_satisfied = {191,255,191},
    notmax = {0,255,0},
    max = {255,255,0},
    selected = {0,255,0},
    unselected = {127,127,127},
  }

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
      v.data.x+cx - self.tree_bg:getWidth()/2,
      v.data.y+cy - self.icon_bg:getHeight()/2-font:getHeight(),
      self.tree_bg:getWidth(),"center")

    love.graphics.printf("[0/"..v.data.maxlevel.."]",
      v.data.x+cx - self.tree_bg:getWidth()/2,
      v.data.y+cy + self.icon_bg:getHeight()/2,
      self.tree_bg:getWidth(),"center")

    love.graphics.setColor(255,255,255)

  end
end

function state:mousepressed(x,y,b)
  local cx,cy = self:getOffset()

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

return state
