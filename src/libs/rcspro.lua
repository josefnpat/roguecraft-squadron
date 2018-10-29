local rcspro = {}

function rcspro.new(init)
  init = init or {}
  local self = {}

  self.start = rcspro.start
  self.stop = rcspro.stop
  self.report = rcspro.report
  self.disable = rcspro.disable
  self.enable = rcspro.enable

  self._data = {}
  self._enable = true

  return self
end

function rcspro:start(tag)
  if self._enable then
    self._data[tag] = self._data[tag] or {current=0}
    self._data[tag].start = love.timer.getTime()
  end
end

function rcspro:stop(tag)
  if self._enable then
    local stop = love.timer.getTime()
    local time = stop - self._data[tag].start
    self._data[tag].current = self._data[tag].current + time
    self._data[tag].start = nil
  end
end

local function as_ms(n)
  return math.floor(n*1000*1000).." ns"
end

function rcspro:report()
  local s = "Report:\n"
  for tag,value in pairs(self._data) do
    s = s .. as_ms(value.current).."\t"..tag.."\n"
  end
  return s
end

function rcspro:disable()
  self._enable = false
end

function rcspro:enable()
  self._enable = true
end

return rcspro
