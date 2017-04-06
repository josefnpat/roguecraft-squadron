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

  if init.helpguides then
    for _,icon_name in pairs(init.helpguides) do
      if tutorial.icons[icon_name] then
        help:addGuide(
          tutorial.icons[icon_name].text,
          tutorial.icons[icon_name].icon)
      else
        print("warning: tutorial icon `"..icon_name.."` does not exist. Skipping.")
      end
    end
  end

  local objective = libs.window.new{
    text = init.objtext or "missing objtext",
    buttons = {
      {
        text = "HINT",
        callback = function()
          self.help = help
        end,
      },
      {
        text = init.skiptext or "SKIP",
        callback = function()
          self.objective = nil
          self.help = nil
        end,
      },
    }
  }

  if init.objguides then
    for _,icon_name in pairs(init.objguides) do
      if tutorial.icons[icon_name] then
        objective:addGuide(
          tutorial.icons[icon_name].text,
          tutorial.icons[icon_name].icon)
      else
        print("warning: tutorial icon `"..icon_name.."` does not exist. Skipping.")
      end
    end
  end

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

tutorial.wait = {}

function tutorial.wait.select_single_object(t)
  local found
  local selected
  for _,object in pairs(states.mission.objects) do
    if object.selected then
      if selected then
        return nil
      else
        selected = object
      end
      if object.type == t then
        if found then
          return nil
        else
          found = object
        end
      end
    end
  end
  return found
end

function tutorial.wait.object_exists(t)
  for _,object in pairs(states.mission.objects) do
    if object.type == t and object.owner == 0 then
      return object
    end
  end
end

tutorial.icons = {}

tutorial.icons.object_command = {
  icon = love.graphics.newImage("assets/objects/command0_icon.png"),
  text = "Command Ship",
}

tutorial.icons.action_repair = {
  icon = love.graphics.newImage("assets/actions/repair.png"),
  text = "Repair",
}

tutorial.icons.object_scrap = {
  icon = love.graphics.newImage("assets/objects/scrap0_icon.png"),
  text = "Scrap",
}

tutorial.icons.object_salvager = {
  icon = love.graphics.newImage("assets/objects/salvager0_icon.png"),
  text = "Salvager",
}

tutorial.icons.object_fighter = {
  icon = love.graphics.newImage("assets/objects/fighter0_icon.png"),
  text = "Fighter",
}

tutorial.icons.object_jump = {
  icon = love.graphics.newImage("assets/objects/jump0_icon.png"),
  text = "Jumpgate Generator",
}

tutorial.icons.action_jump = {
  icon = love.graphics.newImage("assets/actions/jump.png"),
  text = "Jump to next system",
}

return tutorial
