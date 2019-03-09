local windowmanager = {}

function windowmanager.new(init)
  init = init or {}
  local self = {}

  self._windows = {}

  self.add = windowmanager.add
  self.show = windowmanager.show
  self.hide = windowmanager.hide
  self.toggle = windowmanager.toggle
  self.isActive = windowmanager.isActive

  return self
end

function windowmanager:add(window,name)
  assert(self._windows[name]==nil)
  self._windows[name] = window
end

function windowmanager:show(show_name)
  for window_name,window in pairs(self._windows) do
    window:setActive(window_name == show_name)
  end
end

function windowmanager:hide()
  for window_name,window in pairs(self._windows) do
    window:setActive(false)
  end
end

function windowmanager:toggle(toggle_name)
  for window_name,window in pairs(self._windows) do
    if window_name == toggle_name then
      window:setActive(not window:isActive())
    else
      window:setActive(false)
    end
  end
end

function windowmanager:isActive()
  for _,window in pairs(self._windows) do
    if window:isActive() then
      return true
    end
  end
  return false
end

return windowmanager
