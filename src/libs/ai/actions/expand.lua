local action = {}

action.pocket_cache_lifespan = 5

function action:new(init)
  init = init or {}
  local self = {}
  self.ai = init.ai
  self.updateFixed = action.updateFixed
  self.update = action.update

  self._pocket_cache_age = action.pocket_cache_lifespan*math.random()

  self.isValidPocket = action.isValidPocket
  self.isValidPocketFull = action.isValidPocketFull
  self.isValidPocketCached = action.isValidPocketCached
  self.getRemainingPockets = action.getRemainingPockets
  self.getNearestPocket = action.getNearestPocket
  self.buildGlobalPocketCache = action.buildGlobalPocketCache

  return self
end

function action:isValidPocket(ai,pocket,objects)
  for _,object in pairs(objects) do
    local object_type = libs.objectrenderer.getType(object.type)
    if object_type.material_supply or object_type.ore_supply then
      local ax,ay = libs.net.getCurrentLocation(object)
      local nearest_pocket = self:getNearestPocket(ai,ai:getPockets(),ax,ay)
      if pocket == nearest_pocket then
        return true
      end
    end
  end
  return false
end

function action:isValidPocketFull(ai,pocket)
  return self:isValidPocket(ai,pocket,ai:getStorage().objects)
end

function action:isValidPocketCached(ai,pocket)
  local objects = action.pocket_cache[pocket]
  return objects and self:isValidPocket(ai,pocket,objects) or false
end

function action:getRemainingPockets(ai)
  local valid_pockets = {}
  for _,pocket in pairs(ai:getPockets()) do
    if self:isValidPocketFull(ai,pocket) then
      table.insert(valid_pockets,pocket)
    end
  end
  return valid_pockets
end

function action:getNearestPocket(ai,pockets,ax,ay)
  local distance = math.huge
  local nearest = ai:getPockets()[1]
  for _,pocket in pairs(pockets) do
    local adistance = math.sqrt( (ax-pocket.x)^2 + (ay-pocket.y)^2 )
    if adistance < distance then
      distance = adistance
      nearest = pocket
    end
  end
  return nearest,distance
end

function action:buildGlobalPocketCache(ai)
  action.remaining_pockets = self:getRemainingPockets(ai)
  action.pocket_cache = {}
  for _,object in pairs(ai:getStorage().objects) do
    local ax,ay = libs.net.getCurrentLocation(object)
    local pocket = self:getNearestPocket(ai,action.remaining_pockets,ax,ay)
    action.pocket_cache[pocket] = action.pocket_cache[pocket] or {}
    table.insert(action.pocket_cache[pocket],object)
  end
end

function action:updateFixed(ai)
  if action.pocket_cache then
    local current_pocket = ai:getCurrentPocket()
    if not self:isValidPocketCached(ai,current_pocket) then
      local ax,ay = current_pocket.x,current_pocket.y
      local new_pocket = self:getNearestPocket(ai,action.remaining_pockets,ax,ay)
      ai:setCurrentPocket(new_pocket)
    end
  end
  return {},0
end

function action:update(dt,ai)
  self._pocket_cache_age = self._pocket_cache_age + dt
  if self._pocket_cache_age > action.pocket_cache_lifespan then
    self._pocket_cache_age = 0
    action:buildGlobalPocketCache(ai)
  end
end

return action
