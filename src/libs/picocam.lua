local picocam = {}

picocam.new = function(init)
  init = init or {}
  local self = {}
  self.z = init.z or -3
  self.focallength = init.focallength or 5
  self.fov = init.fov or 45
  self.theta = init.theta or 0
  self.width = init.width or 128
  self.height = init.height or 128
  -- public
  self.line = picocam.line
  self.point = picocam.point
  -- private
  self._perspective = picocam._perspective
  self._tan = picocam._tan
  self._coordstopx = picocam._coordstopx
  self._map = picocam._map
  return self
end

picocam.line = function(self, p1, p2)
  local px_1 = self:_coordstopx(self:_perspective(p1))
  local px_2 = self:_coordstopx(self:_perspective(p2))
  love.graphics.line(px_1[1], px_1[2], px_2[1], px_2[2])
  --line(px_1[1], px_1[2], px_2[1], px_2[2])
end

picocam.point = function(self, p)
  local px = self:_coordstopx(self:_perspective(p))
  love.graphics.circle("fill",px[1],px[2],2)
  --pset(px[1],px[2])
end

picocam._perspective = function(self, p)
  local x,y,z = p[1],p[2],p[3]
  local x_rot = x * math.cos(self.theta) - z * math.sin(self.theta)
  local z_rot = x * math.sin(self.theta) + z * math.cos(self.theta)
  local dz = z_rot - self.z
  local out_z = self.z + self.focallength
  local m_xz = x_rot / dz
  local m_yz = y / dz
  local out_x = m_xz * out_z
  local out_y = m_yz * out_z
  return { out_x, out_y }
end

picocam._map = function(v, a, b, c, d)
  local partial = (v - a) / (b - a)
  return partial * (d - c) + c
end

picocam._tan = function(v)
  return math.sin(v) / math.cos(v)
end

picocam._coordstopx = function(self,coords)
  local x = coords[1]
  local y = coords[2]
  --local radius = self.focallength * self._tan(self.fov / 2 / 360)
  local radius = self.focallength * self._tan(self.fov / 2 )
  local pixel_x = self._map(x, -radius, radius, 0, self.width)
  local pixel_y = self._map(y, -radius, radius, 0, self.height)
  return { pixel_x, pixel_y }
end

return picocam
