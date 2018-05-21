-- monkey patches for 0.10.2 to 11.0.0

love.graphics._setColor = love.graphics.setColor
function love.graphics.setColor(r,g,b,a)
  if type(r) == "table" then
    r,g,b,a = r[1],r[2],r[3],r[4]
  end
  love.graphics._setColor(r/255,g/255,b/255,(a or 255)/255)
end

love.graphics._getColor = love.graphics.getColor
function love.graphics.getColor()
  local r,g,b,a = love.graphics._getColor()
  return r*255,g*255,b*255,(a and a*255 or nil)
end

love.audio._newSource = love.audio.newSource
function love.audio.newSource(filename,type)
  return love.audio._newSource(filename,type or "stream")
end

love.filesystem._exists = love.filesystem.exists
function love.filesystem.exists(filename)
  return love.filesystem.getInfo(filename) ~= nil
end
love.setDeprecationOutput(false)
