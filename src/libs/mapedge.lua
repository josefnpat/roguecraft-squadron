local mapedge = {}

function mapedge.new(init)
  init = init or {}
  local self = {}

  self.draw = mapedge.draw
  self.setMapSize = mapedge.setMapSize

  return self
end

function mapedge:draw(camera)
  if self._mapsize then
    love.graphics.setColor(255,0,0,127)
    love.graphics.rectangle("line",
      -self._mapsize-camera.x+love.graphics.getWidth()/2,
      -self._mapsize-camera.y+love.graphics.getHeight()/2,
      self._mapsize*2,self._mapsize*2)
    love.graphics.setColor(255,255,255)
  end
end

function mapedge:setMapSize(map_size_value)
  self._mapsize = libs.net.mapSizes[map_size_value].value
end

return mapedge
