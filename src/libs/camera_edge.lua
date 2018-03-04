local camera_edge = {}

camera_edge.vertical_mouse_move = 1/16.875
camera_edge.horizontal_mouse_move = 1/30
camera_edge_speed = 500

function camera_edge.get_delta(dt)
  local left = love.keyboard.isDown("left","a") or
    love.mouse.getX() < love.graphics.getWidth()*camera_edge.horizontal_mouse_move
  local right = love.keyboard.isDown("right","d") or
    love.mouse.getX() > love.graphics.getWidth()*(1-camera_edge.horizontal_mouse_move)
  local up = love.keyboard.isDown("up","w") or
    love.mouse.getY() < love.graphics.getHeight()*camera_edge.vertical_mouse_move
  local down = love.keyboard.isDown("down","s") or
    love.mouse.getY() > love.graphics.getHeight()*(1-camera_edge.vertical_mouse_move)

  local dx,dy = 0,0
  if left then
    dx = -camera_edge_speed*dt*settings:read("camera_speed")
  end
  if right then
    dx = camera_edge_speed*dt*settings:read("camera_speed")
  end
  if up then
    dy = -camera_edge_speed*dt*settings:read("camera_speed")
  end
  if down then
    dy = camera_edge_speed*dt*settings:read("camera_speed")
  end

  return dx,dy
end

return camera_edge
