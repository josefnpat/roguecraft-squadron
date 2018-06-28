local mpconnect = {}

function mpconnect.new(init)
  init = init or {}
  local self = {}

  self.lovernet = init.lovernet

  self.update = mpconnect.update
  self.draw = mpconnect.draw

  self.start = libs.button.new{
    text="Start Battle",
    onClick=function()
      self.lovernet:pushData(libs.net.op.set_config,{d={game_start=true}})
    end,
  }

  return self
end

function mpconnect:update(dt)
  self.start:update(dt)
end

function mpconnect:draw(config,user_count)
  local s = ""
  s = s .. "user_count: " .. user_count .. "\n"
  s = s .. "get_config:\n"
  if config then
    for i,v in pairs(config) do
      s = s .. "\t" .. i .. ": "..tostring(v) .. "\n"
    end
  end

  self.start:setX( (love.graphics.getWidth()-self.start:getWidth())/2 )
  self.start:setY( love.graphics.getHeight()/2 )
  love.graphics.print(s,self.start:getX(),self.start:getY()+self.start:getHeight())
  self.start:draw()
end

return mpconnect
