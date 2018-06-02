local mpcheese = {}

mpcheese.planet = love.graphics.newImage("assets/planets/BubblegumPlanet.png")

function mpcheese.new(init)
  init = init or {}
  local self = {}

  self.user_object_count = {}
  self.game_start = false
  self.rotate = 0

  self.draw = mpcheese.draw
  self.updateObject = mpcheese.updateObject
  self.clear = mpcheese.clear
  self.update = mpcheese.update
  self.waiting = mpcheese.waiting

  return self
end

function mpcheese:draw(user,camera)
  -- no ur a hack jesus it's 5 am holy crap
  local game_status
  if self.game_start then
    local uoc = 0
    for i,v in pairs(self.user_object_count) do
      uoc = uoc + 1
    end
    if uoc == 1 then
      game_status = "DEFEAT"
      if self.user_object_count[user.id] then
        game_status = "VICTORY"
      end
    end
  else
    game_status = "PLEASE WAIT FOR OPPONENT"
  end

  if game_status then

    if not debug_mode then
      love.graphics.setColor(0,0,0,191)
      love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
      love.graphics.setColor(255,255,255)
      love.graphics.draw(mpcheese.planet,
        love.graphics.getWidth()/2,
        love.graphics.getHeight()/2,
        self.rotate/10,1,1,
        mpcheese.planet:getWidth()/2,
        mpcheese.planet:getHeight()/2)
    end
    love.graphics.setColor(255,255,255)
    love.graphics.setFont(fonts.title)
    love.graphics.printf("["..game_status.."]",
      0,(love.graphics.getHeight()-fonts.title:getHeight())/2,
      love.graphics.getWidth(),"center")
    love.graphics.setFont(fonts.default)
  end

end

function mpcheese:updateObject(object)
  if object.user then
    self.user_object_count[object.user] = (self.user_object_count[object.user] or 0) + 1
  end
end

function mpcheese:clear()
  self.user_object_count = {}
end

function mpcheese:update(dt,user_count,objects)
  self.rotate = self.rotate + dt
  if user_count and user_count > 1 and #objects > 0 then
    self.game_start = true
  end
end

function mpcheese:waiting()
  return not self.game_start
end

return mpcheese
