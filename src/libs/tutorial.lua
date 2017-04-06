local tutorial = {}

function tutorial.new(init)
  init = init or {}
  local self = {}

  self.draw = tutorial.draw
  self.update = tutorial.update
  self.add = tutorial.add
  self.inArea = tutorial.inArea

  self.data = {}

  return self
end

function tutorial:draw()
  if self.objective then
    self.objective:draw()
  end
  if self.help then
    self.help:draw()
  end
end

function tutorial:update(dt)
  if self.skip and self.skip() then
    self.objective = nil
    self.help = nil
  end
  if self.objective then
    self.objective.x = love.graphics.getWidth()-320-32
    self.objective.y = love.graphics.getHeight()-self.objective.h-32
    self.objective:update(dt)
  else
    if #self.data > 0 then
      local data = table.remove(self.data,1)
      self.objective = data.objective
      self.skip = data.skip
    end
  end
  if self.help then
    self.help.x = love.graphics.getWidth()-320-32
    self.help.y = love.graphics.getHeight()-self.help.h-self.objective.h-32
    self.help:update(dt)
  end
end

function tutorial:add(init)
  init = init or {}
  local help = libs.window.new{
    text = init.helptext or "missing helptext",
    color = {255,255,0},
    buttons = {
      {
        text= "THANKS",
        callback = function()
          self.help = nil
        end,
      },
    }
  }
  local objective = libs.window.new{
    text = init.objtext or "missing objtext",
    buttons = {
      {
        text = "HELP",
        callback = function()
          self.help = help
        end,
      },
      {
        text = "CONTINUE",
        callback = function()
          self.objective = nil
          self.help = nil
        end,
      },
    }
  }

  help.y = love.graphics.getHeight()-help.h-objective.h-32

  table.insert(self.data,{
    objective=objective,
    skip=init.skip,
  })

end

function tutorial:inArea()
  return (self.objective and self.objective:inArea()) or
    (self.help and self.help:inArea())
end


return tutorial
