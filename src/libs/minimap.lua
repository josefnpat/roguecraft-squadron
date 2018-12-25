local minimap = {}

function minimap.new(init)
  init = init or  {}
  local self = {}

  self.setMapSize = minimap.setMapSize
  self.mouseInside = minimap.mouseInside
  self.moveToMouse = minimap.moveToMouse
  self.getRealCoords = minimap.getRealCoords

  self.x = init.x or 32
  self.y = init.y or 32
  self.size = init.size or 192
  self.scale = init.scale or 1
  self.fow_mult = init.fow_mult or 1.5
  self.fow_image_size = init.fow_image_size or 1024

  self.draw = minimap.draw

  return self
end

function minimap:setMapSize(map_size_value)
  local mapsize = libs.net.mapSizes[map_size_value].value
  self.scale = mapsize/self.size*2
end

function minimap:mouseInside()
  local mx,my = love.mouse.getPosition()
  return mx >= self.x and mx <= self.x+self.size and my >= self.y and my <= self.y+self.size
end

function minimap:moveToMouse(camera)
  local nx,ny = self:getRealCoords()
  camera:move(-camera.x + nx, -camera.y + ny)
end

function minimap:getRealCoords()
  local ox,oy = self.size/2,self.size/2
  local nx = (love.mouse.getX()-self.x-ox)*self.scale
  local ny = (love.mouse.getY()-self.y-oy)*self.scale
  return nx,ny
end

function minimap:draw(camera,focus,objects,fow,players,user,disable)

  local fow_map = fow:getMap()
  local x,y,w,h = self.x, self.y,self.size,self.size
  tooltipbg(x,y,w,h)
  love.graphics.setScissor(x,y,w,h)
  local scale = self.scale
  local ox,oy = self.size/2,self.size/2

  love.graphics.setColor(0,0,0,127)
  for fow_obj_x,fow_obj_row in pairs(fow_map) do
    for fow_obj_y,fow_obj_val in pairs(fow_obj_row) do
      love.graphics.circle("fill",
        x+ox+fow_obj_x/scale,
        y+oy+fow_obj_y/scale,
        self.fow_image_size/scale/2*1)
    end
  end

  if debug_mode then
    for _,object in pairs(objects) do
      if focus.user == object.user then
        love.graphics.setColor(255,255,255,63)
        local object_type = libs.objectrenderer.getType(object.type)
        -- don't forget canvas mask
        local fow = self.fow_mult*(object_type.fow or 1)--*(1+(self.upgrades.fow or 0)*0.25)

        love.graphics.circle("fill",
          x+ox+object.dx/scale,y+oy+object.dy/scale,
          self.fow_image_size/scale/2*fow)
      end
    end
  end

  for _,object in pairs(objects) do

    if disable or libs.net.isOnSameTeam(players,object.user,user.id) or fow:objectVisible(object) then
      local type = libs.objectrenderer.getType(object.type)
      local color = {255,255,0,127}
      if object.user then
        local cuser = libs.net.getUser(object.user)
        color = cuser.selected_color
      end
      if type.minimap ~= false then
        love.graphics.setColor(color)
        love.graphics.rectangle("fill",
          x+ox+object.dx/scale-2,y+oy+object.dy/scale-2,4,4)
        love.graphics.setColor(255,255,255,127)
        love.graphics.rectangle("line",
          x+ox+object.dx/scale-1.5,y+oy+object.dy/scale-1.5,4,4)
      end
      if object.in_combat then
        love.graphics.setColor(255,0,0)
        love.graphics.circle("line",
          x+ox+object.dx/scale,
          y+oy+object.dy/scale,
          6+math.sin(love.timer.getTime()*4))
      end
    end

  end
  love.graphics.setColor(255,255,255)
  local cx = (camera.x-love.graphics.getWidth()/2)/scale
  local cy = (camera.y-love.graphics.getHeight()/2)/scale
  local cw = love.graphics.getWidth()/scale
  local ch = love.graphics.getHeight()/scale
  love.graphics.rectangle("line",x+ox+cx,y+oy+cy,cw,ch)

  love.graphics.setScissor()
  love.graphics.setColor(255,255,255)

end

return minimap
