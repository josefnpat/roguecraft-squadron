local controlgroups = {}

function controlgroups.new(init)
  init = init or {}
  local self = {}
  self._data = {}
  self.update = controlgroups.update
  self.keypressed = controlgroups.keypressed
  return self
end

function controlgroups:update(dt)
  if self.last_selected_timeout then
    self.last_selected_timeout = self.last_selected_timeout - dt
    if self.last_selected_timeout <= 0 then
      self.last_selected_timeout = nil
      self.last_selected = nil
    end
  end
end

function controlgroups:keypressed(key,selection,notif,user,onDoubleSelect)
  local key_number
  if key:sub(1,2) == "kp" then
    key_number = tonumber(key:sub(3))
  else
    key_number = tonumber(key)
  end
  if key_number ~= nil and key_number >= 0 and key_number <= 9 then
    if love.keyboard.isDown("lshift") then
      local valid = true
      local selected = selection:getSelected()
      for _,object in pairs(selected) do
        if object.user ~= user.id then
          valid = false
        end
      end
      if valid and #selected > 0 then
        -- add to controlgroup
        for _,objectToAdd in pairs(selected) do

          local found = false
          for _,objectSelected in pairs(self._data[key_number] or {}) do
            if objectSelected == objectToAdd then
              found = true
              break
            end
          end
          if not found then
            self._data[key_number] = self._data[key_number] or {}
            table.insert(self._data[key_number],objectToAdd)
          end

        end
        notif:add(libs.i18n('mission.notification.controlgroup.set',{group=key_number}),nil,nil,nil,1)

      end
    elseif love.keyboard.isDown("lctrl") then

      local valid = true
      local selected = selection:getSelected()
      for _,object in pairs(selected) do
        if object.user ~= user.id then
          valid = false
        end
      end
      if valid and #selected > 0 then
        -- set controlgroup
        self._data[key_number] = selected
        notif:add(libs.i18n('mission.notification.controlgroup.set',{group=key_number}),nil,nil,nil,1)
      end

    else
      -- change to controlgroup
      if self._data[key_number] then
        if self.last_selected == nil or self.last_selected ~= key_number then
          self.last_selected = key_number
          self.last_selected_timeout = 0.5 -- default for windows
        else
          onDoubleSelect()
        end
        selection:setSelected(self._data[key_number])
        notif:add(libs.i18n('mission.notification.controlgroup.use',{group=key_number}),nil,nil,nil,1)
      end
    end
  end
end

return controlgroups
