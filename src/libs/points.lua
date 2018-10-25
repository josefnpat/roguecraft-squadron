local points = {}

points.icon = love.graphics.newImage("assets/hud/points.png")

function points.new(init)
  init = init or {}
  local self = {}

  self.panelShown = points.panelShown
  self.setPointsValue = points.setPointsValue
  self.getPointsValue = points.getPointsValue
  self.getMax = points.getMax
  self.getRate = points.getRate
  self._points = init.points or 1
  self._pointsValue = math.huge
  self.setPoints = points.setPoints
  self.hasPoints = points.hasPoints

  self.draw = points.draw
  self.update = points.update
  self.setX = points.setX
  self.setY = points.setY
  self.getHeight = points.getHeight
  self.mouseInside = points.mouseInside

  self._bar = libs.bar.new{
    icon = points.icon,
  }

  return self
end

function points:panelShown()
  local max = libs.net.points[self._points].value
  return self._pointsValue > 0 and max ~= math.huge
end

function points:setPointsValue(val)
  self._pointsValue = val
  local max = libs.net.points[self._points].value
  local rate = max == math.huge and 1 or math.min(1,val/max)
  local percent = math.floor(val/max*100)
  self._bar:setText("Capacity: "..percent.."%")
  self._bar:setHoverText(val.."/"..tostring(libs.net.points[self._points].value) .. " ["..percent.."%]")
  self._bar:setBarValue(rate)
end

function points:getPointsValue()
  return self._pointsValue
end

function points:getMax()
  return libs.net.points[self._points].value
end

function points:getRate()
  local max = libs.net.points[self._points].value
  if max == math.huge then
    return 0
  else
    return math.min(1,self._pointsValue/max)
  end
end

function points:setPoints(points)
  self._points = points
end

function points:hasPoints(object_type)
  return libs.net.hasPoints(self._pointsValue,self._points,object_type)
end

function points:draw()
  self._bar:draw()
end

function points:update(dt)
  self._bar:update(dt)
end

function points:setX(val)
  self._bar:setX(val)
end

function points:setY(val)
  self._bar:setY(val)
end

function points:getHeight()
  return self._bar:getHeight()
end

function points:mouseInside()
  return self._bar:mouseInside()
end

return points
