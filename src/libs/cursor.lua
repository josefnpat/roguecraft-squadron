local cursor = {
  types = {},
}

function cursor.update(dt)
  if cursor.current_mode ~= cursor.target_mode then
    cursor.current_mode = cursor.target_mode
    local is_visible = cursor.current_mode == "hardware"
    love.mouse.setVisible(is_visible)
  end
  if cursor.current ~= cursor.target then
    cursor.current = cursor.target
    if cursor.current_mode == "hardware" then
      love.mouse.setCursor(cursor.current and cursor.current.hardware or cursor.default.hardware)
    end
  end
end

function cursor.add(t,uri)
  assert(cursor.types[t] == nil)
  assert(t)
  assert(uri)
  assert(type(uri)=="string")
  local image = love.graphics.newImage(uri)
  cursor.types[t] = {
    hardware = love.mouse.newCursor(uri,image:getWidth()/2,image:getHeight()/2),
    software = image,
  }
  cursor.default = cursor.default or cursor.types[t]
end

function cursor.change(t)
  assert(t)
  assert(cursor.types[t])
  cursor.target = cursor.types[t]
end

function cursor.mode(val)
  assert(val)
  assert(val=="hardware" or val=="software")
  cursor.target_mode = val
end

function cursor.draw()
  if cursor.current_mode == "software" then
    love.graphics.setColor(255,255,255)
    local image = cursor.current and cursor.current.software or cursor.default.software
    love.graphics.draw(image,
      love.mouse.getX(),love.mouse.getY(),0,1,1,
      cursor.current.software:getWidth()/2,
      cursor.current.software:getHeight()/2)
  end
end

return cursor
