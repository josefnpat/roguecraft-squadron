local cursor = {
  types = {},
}

function cursor.update(dt)
  if cursor.current ~= cursor.target then
    cursor.current = cursor.target
    love.mouse.setCursor(cursor.current or cursor.default)
  end
end

function cursor.add(t,uri)
  assert(cursor.types[t] == nil)
  assert(t)
  assert(uri)
  assert(type(uri)=="string")

  local image = love.graphics.newImage(uri) -- garbage

  cursor.types[t] = love.mouse.newCursor(
    uri,
    image:getWidth()/2,
    image:getHeight()/2)

  cursor.default = cursor.default or cursor.types[t]

end

function cursor.change(t)
  assert(t)
  assert(cursor.types[t])

  cursor.target = cursor.types[t]

end

return cursor
