local tutorial = {}

function tutorial.new(init)
  init = init or {}
  local self = {}

  self.draw = tutorial.draw
  self.update = tutorial.update
  self.add = tutorial.add
  self.inArea = tutorial.inArea

  self.data = {}

  tutorial.load_icons()

  self._dt = 0
  self._auto_help = false

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

  if self.data[self.data_index] then
    self._dt = self._dt + dt
    if self._dt > 30 then
      if self._auto_help == false then
        self.help = self.objective.__help
        self._auto_help = true
      end
    end
  end

  if self.objective then

    if self.complete and self.complete() then
      self.objective.color = {0,255,0}
      self.objective.title = libs.i18n('tutorial.title.complete')
      if self.objective.buttons[3] then
        self.objective.buttons[3].text = libs.i18n('tutorial.buttons.continue')
      end
    end

    self.objective.x = love.graphics.getWidth()-320-self.padding
    self.objective.y = love.graphics.getHeight()-self.objective.h-self.padding
    self.objective:update(dt)
  else
    if self.data_index == nil then
      --nop
    elseif self.data[self.data_index] then--#self.data > 0 then
      --local data = table.remove(self.data,1)
      local data = self.data[self.data_index]
      self.objective = data.objective
      self.objective:reset()
      self.complete = data.complete
    end
  end
  if self.help then
    self.help.x = love.graphics.getWidth()-320-self.padding
    self.help.y = love.graphics.getHeight()-self.help.h-self.objective.h-self.padding
    self.help:update(dt)
  end
end

function tutorial:add(init)
  init = init or {}

  self.padding = init.padding or 64

  self.data_index = self.data_index or 1

  local help = libs.window.new{
    text = init.helptext or "missing helptext",
    color = {255,255,0},
    image = init.helpimage,
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

  local back = {
    text = init.backtext or "BACK",
    callback = function()
      self.data_index = self.data_index - 1
      self.objective = nil
      self.help = nil
      self._dt = 0
      self._auto_help = false
    end,
  }

  local hint = {
    text = "HINT",
    callback = function()
      self.help = help
    end,
  }

  local skip = {
    text = init.completetext or "SKIP",
    callback = function()
      self.data_index = self.data_index + 1
      self.objective = nil
      self.help = nil
      self._dt = 0
      self._auto_help = false
    end,
  }

  local objective = libs.window.new{
    title = init.title or libs.i18n('tutorial.title.in_progress'),
    text = init.objtext or "missing objtext",
    color = {127,127,255},
    image = init.objimage,
    buttons = #self.data > 0 and {back,hint,skip} or {hint,skip}
  }

  objective.__help = help

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

  help.y = love.graphics.getHeight()-help.h-objective.h-self.padding

  table.insert(self.data,{
    objective=objective,
    complete=init.complete,
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

function tutorial.wait.object_is_target(t)
  for _,object in pairs(states.mission.objects) do
    if object.target_object and object.target_object.type == t then
      return object
    end
  end
end

function tutorial.wait.objects_find(t)
  local objects = {}
  for _,object in pairs(states.mission.objects) do
    if object.type == t then
      table.insert(objects,object)
    end
  end
  return objects
end

function tutorial.wait.camera_moved(t)
  return states.mission.camera.x > love.graphics.getWidth() or
    states.mission.camera.y > love.graphics.getHeight()
end

function tutorial.load_icons()

  tutorial.icons = {}

  tutorial.icons.object_command = {
    icon = love.graphics.newImage("assets/objects_icon/command0.png"),
    text = libs.i18n('mission.object.command.name'),
  }

  tutorial.icons.action_repair = {
    icon = love.graphics.newImage("assets/actions/repair.png"),
    text = libs.i18n('mission.action.repair.base'),
  }

  tutorial.icons.object_scrap = {
    icon = love.graphics.newImage("assets/objects_icon/scrap0.png"),
    text = libs.i18n('mission.object.scrap.name'),
  }

  tutorial.icons.object_salvager = {
    icon = love.graphics.newImage("assets/objects_icon/salvager0.png"),
    text = libs.i18n('mission.object.salvager.name'),
  }

  tutorial.icons.object_fighter = {
    icon = love.graphics.newImage("assets/objects_icon/fighter0.png"),
    text = libs.i18n('mission.object.fighter.name'),
  }

  tutorial.icons.object_jump = {
    icon = love.graphics.newImage("assets/objects_icon/jump0.png"),
    text = libs.i18n('mission.object.jump.name'),
  }

  tutorial.icons.object_enemy_jumpscrambler = {
    icon = love.graphics.newImage("assets/objects_icon/enemy_jumpscrambler0.png"),
    text = libs.i18n('mission.object.enemy_jumpscrambler'),
  }

  tutorial.icons.action_jump = {
    icon = love.graphics.newImage("assets/actions/jump.png"),
    text = libs.i18n('mission.action.jump.base'),
  }

  tutorial.icons.object_enemy_fighter = {
    icon = love.graphics.newImage("assets/objects_icon/enemy_fighter0.png"),
    text = libs.i18n('mission.object.enemy_fighter.name'),
  }

  tutorial.icons.object_drydock = {
    icon = love.graphics.newImage("assets/objects_icon/drydock0.png"),
    text = libs.i18n('mission.object.drydock.name'),
  }

  tutorial.icons.object_combat = {
    icon = love.graphics.newImage("assets/objects_icon/combat0.png"),
    text = libs.i18n('mission.object.combat.name'),
  }

  tutorial.icons.object_advdrydock = {
    icon = love.graphics.newImage("assets/objects_icon/advdrydock0.png"),
    text = libs.i18n('mission.object.advdrydock.name'),
  }

  tutorial.icons.object_artillery = {
    icon = love.graphics.newImage("assets/objects_icon/artillery0.png"),
    text = libs.i18n('mission.object.artillery.name'),
  }

  tutorial.icons.object_tank = {
    icon = love.graphics.newImage("assets/objects_icon/tank0.png"),
    text = libs.i18n('mission.object.tank.name'),
  }

  tutorial.icons.object_mining = {
    icon = love.graphics.newImage("assets/objects_icon/mining0.png"),
    text = libs.i18n('mission.object.mining.name'),
  }

  tutorial.icons.object_asteroid = {
    icon = love.graphics.newImage("assets/objects_icon/asteroid0.png"),
    text = libs.i18n('mission.object.asteroid.name'),
  }

  tutorial.icons.object_refinery = {
    icon = love.graphics.newImage("assets/objects_icon/refinery0.png"),
    text = libs.i18n('mission.object.refinery.name'),
  }

  tutorial.icons.action_refine = {
    icon = love.graphics.newImage("assets/actions/refine.png"),
    text = libs.i18n('mission.action.refine.base'),
  }

  tutorial.icons.action_cta = {
    icon = love.graphics.newImage("assets/actions/cta.png"),
    text = libs.i18n('mission.action.cta.base'),
  }

  tutorial.icons.action_collect = {
    icon = love.graphics.newImage("assets/actions/collect.png"),
    text = libs.i18n('mission.action.collect.base'),
  }

  tutorial.icons.action_lmb = {
    icon = love.graphics.newImage("assets/actions/lmb.png"),
    text = libs.i18n('mission.action.lmb'),
  }

  tutorial.icons.action_rmb = {
    icon = love.graphics.newImage("assets/actions/rmb.png"),
    text = libs.i18n('mission.action.rmb'),
  }

end

return tutorial
