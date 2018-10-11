local resources = {}

resources._tween_speed = 1000

function resources.new(init)
  init = init or {}
  local self = {}
  self.x = init.x or 32
  self.y = init.y or 32
  self.size = init.size or 192
  self.notif = init.notif

  self.draw = resources.draw
  self.updateBars = resources.updateBars
  self.update = resources.update
  self.calcCargo = resources.calcCargo
  self.set = resources.set
  self.setFull = resources.setFull
  self.canAfford = resources.canAfford
  self.canAffordResType = resources.canAffordResType
  self.cantAffordNotif = resources.cantAffordNotif
  self.mouseInside = resources.mouseInside
  self.getHeight = resources.getHeight

  local resourceIcons = {}
  self._value = {}
  self._delta = {}
  self._cargo = {}
  self._value_tween = {}
  for _,restype in pairs(libs.net.resourceTypes) do
    resourceIcons[restype] = love.graphics.newImage("assets/resources/"..restype..".png")
    self._value[restype] = 0
    self._value_tween[restype] = 0
    self._delta[restype] = 0
    self._cargo[restype] = 0
  end

  self.resourceBars = {}

  for restype_index,restype in pairs(libs.net.resourceTypes) do

    self.resourceBars[restype] = libs.bar.new{
      text = function()
        return libs.net.resourceStrings[restype] .. ": " .. math.floor(self._value_tween[restype])
      end,
      hoverText = function()
        local percent = 0
        if self._cargo[restype] > 0 then
          percent = math.floor(self._value[restype]/self._cargo[restype]*100)
        end
        return math.floor(self._value_tween[restype]).."/"..self._cargo[restype].." ["..percent.."%]"
      end,
      width = self.size,
      icon = resourceIcons[restype],
      barValue = 0,
    }

  end

  return self
end

function resources:updateBars(dt)
  local current = 0
  for _,restype in pairs(libs.net.resourceTypes) do
    self.resourceBars[restype]:update(dt)
    local enabled = self._cargo[restype] > 0
    self.resourceBars[restype]:setBarEnable(enabled)
    if enabled then
      local barValue = self._value_tween[restype]/self._cargo[restype]
      self.resourceBars[restype]:setBarValue(barValue)
      self.resourceBars[restype]:setX(self.x)
      self.resourceBars[restype]:setY(self.y+current)
      current = current + self.resourceBars[restype]:getHeight()
    end
  end
end

function resources:update(dt)
  self:updateBars(dt)
  for _,restype in pairs(libs.net.resourceTypes) do
    local delta = self._value[restype] - self._value_tween[restype]
    if delta > 1 then
      self._value_tween[restype] = self._value_tween[restype] + delta*dt*4
    else
      self._value_tween[restype] = self._value[restype]
    end
  end
end

function resources:draw()
  for i,bar in pairs(self.resourceBars) do
    bar:draw()
  end
end

function resources:calcCargo(objects,user)

  for _,restype in pairs(libs.net.resourceTypes) do
    self._cargo[restype] = 0
  end

  for _,object in pairs(objects) do
    if object.user == user.id then
      local object_type = libs.objectrenderer.getType(object.type)
      for _,restype in pairs(libs.net.resourceTypes) do
        if object_type[restype] then
          self._cargo[restype] = self._cargo[restype] + object_type[restype]
        end
      end
    end
  end

end

function resources:set(restype,value)
  if self._value[restype] == nil then
    print("warning: resource type `"..tostring(restype).."` does not exist.")
  else
    if self._value[restype] ~= self._cargo[restype] and value == self._cargo[restype] then
      self.notif:add(
        libs.i18n('mission.notification.cargo_full.'..restype),
        nil,
        {63,63,15,256*7/8},
        {255,255,0}
      )
      libs.sfx.loopGroup("cargo_full."..restype)
    end
    self._value[restype] = value
  end
end

function resources:setFull(res)
  for restype,value in pairs(res) do
    self:set(restype,value)
  end
end

function resources:canAfford(object_type)
  if object_type.cost == nil then return true end
  for restype,value in pairs(object_type.cost) do
    if self._value[restype] < value then
      return false
    end
  end
  return true
end

function resources:canAffordResType(object_type,restype)
  return self._value[restype] >= object_type.cost[restype]
end

function resources:cantAffordNotif(object_type)
  local trestype = "multiple"
  for restype,value in pairs(object_type.cost) do
    if self._value[restype] < value then
      if trestype then
        trestype = "multiple"
      else
        trestype = restype
      end
    end
  end
  assert(trestype)
  libs.sfx.loopGroup("cant_afford."..trestype)
  self.notif:add(
    libs.i18n('mission.notification.cant_afford.'..trestype),
    nil,
    {63,63,15,256*7/8},
    {255,255,0}
  )
end

function resources:mouseInside()
  for i,bar in pairs(self.resourceBars) do
    if bar:mouseInside() then
      return true
    end
  end
  return false
end

function resources:getHeight()
  --local enabled = 0
  local height = 0
  for _,bar in pairs(self.resourceBars) do
    if bar:getBarEnable() then
      height = height + bar:getHeight()
    end
  end
  return height
end

return resources
