local mission = {}

function mission:init()
  self.ships = {
    pirate = love.graphics.newImage("ships/Pirate.png"),
    dove = love.graphics.newImage("ships/Dove.png"),
    ligher = love.graphics.newImage("ships/Ligher.png"),
    lightning = love.graphics.newImage("ships/Lightning.png"),
    ninja = love.graphics.newImage("ships/Ninja.png"),
    paranoid = love.graphics.newImage("ships/Paranoid.png"),
    saboteur = love.graphics.newImage("ships/Saboteur.png"),
    turtle = love.graphics.newImage("ships/Turtle.png"),
    ufo = love.graphics.newImage("ships/UFO.png"),
  }
  self.camera = libs.hump.camera(1280/2,720/2)
  self.camera_speed = 300
  self.camera.vertical_mouse_move = 1/20
  self.camera.horizontal_mouse_move = 1/11.25
  self.stars = love.graphics.newImage("stars.png")
  self.stars:setWrap("repeat","repeat")
  self.stars_quad = love.graphics.newQuad(0, 0, 1280+self.stars:getWidth(), 720+self.stars:getHeight(),
    self.stars:getWidth(), self.stars:getHeight())
end

function mission:randomShipType()
  local ships = {}
  for i,v in pairs(self.ships) do
    table.insert(ships,i)
  end
  return ships[math.random(#ships)]
end

function mission:enter()
  self.objects = {}
  for i = 1,100 do
    table.insert(self.objects,{
      type = self:randomShipType(),
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
  if self:mouseInMiniMap() then
  else
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
              local ox,oy = self:getcameraoffset()
              object.target = {x=gx*grid_size+ox,y=gy*grid_size+oy}
              found = true
            end
            range = range + 0.1
          end
        end
      end
    end
  end
end

function mission:getcameraoffset()
  return self.camera.x-1280/2,self.camera.y-720/2
end

function mission:mousereleased(x,y,b)
  if b == 1 then
    if self.select_start then
      for _,object in pairs(self.objects) do
        local ox,oy = self:getcameraoffset()
        local xmin,ymin,xmax,ymax = self:selectminmax(self.select_start.x+ox,self.select_start.y+oy,x+ox,y+oy)
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
  love.graphics.draw(self.stars, self.stars_quad,
    -self.stars:getWidth()+(self.camera.x%self.stars:getWidth()),
    -self.stars:getHeight()+(self.camera.y%self.stars:getHeight()) )
  self.camera:attach()
  for _,object in pairs(self.objects) do
    love.graphics.setColor(object.selected and 0 or 255,255,object.selected and 0 or 255,63)
    love.graphics.circle("line",object.position.x,object.position.y,object.size)
    love.graphics.setColor(255,255,255)
    local ship = self.ships[object.type]
    love.graphics.draw(ship,
      object.position.x,object.position.y,
      object.angle or 0,1,1,ship:getWidth()/2,ship:getHeight()/2)
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

  self:drawMinimap()

end

function mission:miniMapArea()
  return 32,32,128,128
end

function mission:miniMapScale()
  return 64
end

function mission:mouseInMiniMap()
  local x,y,w,h = self:miniMapArea()
  local mx,my = love.mouse.getPosition()
  return mx >= x and mx <= x+w and my >= y and my <= my+h
end

function mission:drawMinimap()
  local x,y,w,h = self:miniMapArea()
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill",x,y,w,h)
  local scale = self:miniMapScale()
  love.graphics.setColor(0,255,0)
  love.graphics.rectangle("line",x,y,w,h)
  local cx,cy,cw,ch = (self.camera.x-1280/2)/scale,(self.camera.y-720/2)/scale,1280/scale,720/scale
  love.graphics.rectangle("line",x+cx,y+cy,cw,ch)
  for _,object in pairs(self.objects) do
    love.graphics.points(x+object.position.x/scale,y+object.position.y/scale)
  end
  love.graphics.setColor(255,255,255)
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

  if not self.select_start then

    if self:mouseInMiniMap() then
      if love.mouse.isDown(1) then
        local x,y,w,h = self:miniMapArea()
        local nx = (love.mouse.getX()-x)*self:miniMapScale()
        local ny = (love.mouse.getY()-y)*self:miniMapScale()
        self.camera:move(-self.camera.x + nx, -self.camera.y + ny)
      end
    else

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

  end

end

return mission
