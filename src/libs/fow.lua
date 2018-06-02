local fow = {}

function fow.new(init)
  init = init or {}
  local self = {}

  self.camera = init.camera

  self.getMap = fow.getMap
  self.resize = fow.resize
  self.draw = fow.draw
  self.drawSingle = fow.drawSingle
  self.update = fow.update
  self.objectVisible = fow.objectVisible

  self.fow_map = {}
  self:resize()
  self.fow_img = love.graphics.newImage("assets/fow.png")
  self.fow_mult = 1.5
  self.resolution = 128
  self.resolution_mult = 1024/self.resolution/2

  return self
end

function fow:objectVisible(object)
  for x,row in pairs(self.fow_map) do
    for y,node in pairs(row) do
      local distance = math.sqrt( (x-object.dx+self.resolution/2)^2 + (y-object.dy+self.resolution/2)^2  )
      if distance < self.resolution*self.resolution_mult then
        return true
      end
    end
  end
  return false
end

function fow:getMap()
  return self.fow_map
end

function fow:resize()
  self.fow = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
end

function fow:drawSingle(fow_obj_x,fow_obj_y,fow_scale,fow_rot,fow_alpha)

  love.graphics.setColor(255,255,255,fow_alpha)

  local x = fow_obj_x-self.camera.x+love.graphics.getWidth()/2
  local y = fow_obj_y-self.camera.y+love.graphics.getHeight()/2

  if settings:read("fow_quality") == "img_canvas" then
    love.graphics.draw(self.fow_img,x,y,
      fow_rot,fow_scale,fow_scale,
      self.fow_img:getWidth()/2,
      self.fow_img:getHeight()/2)
  else
    love.graphics.setColor(0,0,0,fow_alpha)
    love.graphics.circle("fill",x,y,512*fow_scale)
    love.graphics.setColor(255,255,255)
  end

end

function fow:draw(objects,explosions,user)

  if debug_mode then
    for fow_obj_x,fow_obj_row in pairs(self.fow_map) do
      for fow_obj_y,fow_obj_val in pairs(fow_obj_row) do
        local x = fow_obj_x-self.camera.x+love.graphics.getWidth()/2
        local y = fow_obj_y-self.camera.y+love.graphics.getHeight()/2
        love.graphics.print("fow",x,y)
      end
    end
  end

  self.fow:renderTo(function()
    love.graphics.clear()
    love.graphics.setColor(255,255,255)
    love.graphics.rectangle("fill",0,0,
      love.graphics.getWidth(),
      love.graphics.getHeight()
    )

    for fow_obj_x,fow_obj_row in pairs(self.fow_map) do
      for fow_obj_y,fow_obj_val in pairs(fow_obj_row) do
        self:drawSingle(fow_obj_x,fow_obj_y,1,0,255/20)
      end
    end

    love.graphics.setColor(255,255,255)

    for _,object in pairs(objects) do
      if object.user == user.id then
        local object_type = libs.objectrenderer.getType(object.type)
        local fow = self.fow_mult*(object_type.fow or 1)--*(1+(self.upgrades.fow or 0)*0.25)
        self:drawSingle(object.dx,object.dy,fow,object.fow_rot)
      end
    end

    -- todo: test this when explosions are implemented
    for _,explosion in pairs(explosions) do
      local percent = 1 - explosion.dt/#self.explosion_images
      local fow_scale = (explosion.fow or 1)*percent
      love.graphics.setColor(255,255,255,percent*255)
      local x = explosion.x-self.camera.x+love.graphics.getWidth()/2
      local y = explosion.y-self.camera.y+love.graphics.getHeight()/2

      if settings:read("fow_quality") == "img_canvas" then
        love.graphics.draw(self.fow_img,x,y,
          explosion.fow_rot,fow_scale,fow_scale,
          self.fow_img:getWidth()/2,
          self.fow_img:getHeight()/2)
      else
        love.graphics.setColor(0,0,0)
        love.graphics.circle("fill",x,y,512*fow_scale)
        love.graphics.setColor(255,255,255)
      end
    end

  end)

  love.graphics.setBlendMode("subtract")
  love.graphics.setColor(255,255,255)
  love.graphics.draw(self.fow)
  love.graphics.setBlendMode("alpha")

end

function fow:update(dt,object)
  object.fow_rot = object.fow_rot and object.fow_rot + dt/60 or math.random()*math.pi*2

  local fow_map_x = math.floor(object.dx/self.resolution)*self.resolution
  local fow_map_y = math.floor(object.dy/self.resolution)*self.resolution
  self.fow_map[fow_map_x] = self.fow_map[fow_map_x] or {}
  self.fow_map[fow_map_x][fow_map_y] = true

end

return fow
