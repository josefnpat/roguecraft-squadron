local mission = {}

function mission:init()
  self.pirateship = love.graphics.newImage("pirateship.png")
  self.camera = libs.hump.camera(1280/2,720/2)
  self.camera_speed = 300
  self.camera.vertical_mouse_move = 1/20
  self.camera.horizontal_mouse_move = 1/11.25
  self.stars = love.graphics.newImage("stars.png")
  self.stars:setWrap("repeat","repeat")
  self.stars_quad = love.graphics.newQuad(0, 0, 1280, 720, self.stars:getWidth(), self.stars:getHeight())
end

function mission:enter()
  self.objects = {}
  for i = 1,100 do
    table.insert(self.objects,{
      position = {
        x = math.random(1280),
        y = math.random(720),
      },
      size = 15,
      speed = math.random(75,100),
    })
  end
end

function mission:mousepressed(x,y,b)
  if b == 1 then
    self.select_start = {x=x,y=y}
  elseif b == 2 then
    local grid = {}
    local grid_size = 32
    for _,object in pairs(self.objects) do
      if not object.selected then
        local sx = object.target and object.target.x or object.position.x
        local sy = object.target and object.target.y or object.position.y
        local gx,gy = math.floor(sx/grid_size),math.floor(sy/grid_size)
        grid[gx] = grid[gx] or {}
        grid[gx][gy] = object
      end
    end
    for _,object in pairs(self.objects) do
      if object.selected then
        local range = 0
        local found = false
        while found == false do
          local rx,ry = x + math.random(-range,range),y + math.random(-range,range)
          local gx,gy = math.floor(rx/grid_size),math.floor(ry/grid_size)
          if not grid[gx] or not grid[gx][gy] then
            grid[gx] = grid[gx] or {}
            grid[gx][gy] = object
            object.target = {x=gx*grid_size,y=gy*grid_size}
            found = true
          end
          range = range + 0.1
        end
      end
    end
  end
end

function mission:mousereleased(x,y,b)
  if b == 1 then
    if self.select_start then
      for _,object in pairs(self.objects) do
        local xmin,ymin,xmax,ymax = self:selectminmax(self.select_start.x,self.select_start.y,x,y)
        object.selected = false
        if object.position.x >= xmin and object.position.x <= xmax and
          object.position.y >= ymin and object.position.y <= ymax then
            object.selected = true
        end
        --print("selecting area:",xmin,ymin,xmax,ymax)
      end
      self.select_start = nil
    end
  end
end

function mission:selectminmax(x,y,x2,y2)
  local xmin = math.min(x,x2)
  local ymin = math.min(y,y2)
  local xmax = math.max(x,x2)
  local ymax = math.max(y,y2)
  return xmin,ymin,xmax,ymax
end

function mission:distance(a,b)
  return math.sqrt( (a.x-b.x)^2 + (a.y-b.y)^2 )
end

function mission:draw()
  love.graphics.draw(self.stars, self.stars_quad, 0, 0)
  self.camera:attach()
  for _,object in pairs(self.objects) do
    love.graphics.setColor(object.selected and 0 or 255,255,object.selected and 0 or 255)
    love.graphics.circle("line",object.position.x,object.position.y,object.size)
    love.graphics.draw(self.pirateship,
      object.position.x,object.position.y,
      object.angle or 0,1,1,self.pirateship:getWidth()/2,self.pirateship:getHeight()/2)
    if object.target and object.selected then
      love.graphics.line(object.position.x,object.position.y,object.target.x,object.target.y)
    end
  end
  self.camera:detach()
  love.graphics.setColor(0,255,0)
  if self.select_start then
    local mx,my = love.mouse.getPosition()
    local xmin,ymin,xmax,ymax = self:selectminmax(self.select_start.x,self.select_start.y,mx,my)
    local w,h = xmax - xmin, ymax - ymin
    love.graphics.rectangle("line",xmin,ymin,w,h)
  end
  love.graphics.setColor(255,255,255)
  --love.graphics.print("camera:"..self.camera.x..":"..self.camera.y)
end

function mission:update(dt)

  for _,object in pairs(self.objects) do
    if object.target then
      local distance = self:distance(object.position,object.target)
      if distance > 4 then
        local dx,dy = object.position.x-object.target.x,object.position.y-object.target.y
        object.angle = math.atan2(dy,dx)+math.pi
        object.position.x = object.position.x + math.cos(object.angle)*dt*object.speed
        object.position.y = object.position.y + math.sin(object.angle)*dt*object.speed
      else
        object.position = object.target
        object.target = nil
      end
    end
  end

  local left = love.keyboard.isDown("left") or love.mouse.getX() < 1280*self.camera.horizontal_mouse_move
  local right = love.keyboard.isDown("right") or love.mouse.getX() > 1280*(1-self.camera.horizontal_mouse_move)
  local up = love.keyboard.isDown("up") or love.mouse.getY() < 720*self.camera.vertical_mouse_move
  local down = love.keyboard.isDown("down") or love.mouse.getY() > 720*(1-self.camera.vertical_mouse_move)

  local dx,dy = 0,0
  if left then
    dx = -self.camera_speed*dt
  end
  if right then
    dx = self.camera_speed*dt
  end
  if up then
    dy = -self.camera_speed*dt
  end
  if down then
    dy = self.camera_speed*dt
  end
  self.camera:move(dx,dy)

end

return mission
