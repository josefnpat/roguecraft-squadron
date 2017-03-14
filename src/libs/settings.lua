local settings = {}

function settings.new(init)
  init = init or {}
  local self = {}
  self._filename = init.filename or "settings.json"
  self._json = init.json or require"libs.json"

  self.read = settings.read
  self.write = settings.write
  self.load = settings.load
  self.save = settings.save

  self._data = {}
  return self
end

function settings:read(name,default)
  return self._data[name] or default
end

function settings:write(name,value)
  self._data[name] = value
end

function settings:load()
  if love.filesystem.exists(self._filename) then
    local raw = love.filesystem.read(self._filename)
    self._data = self._json.decode(raw)
  end
end

function settings:save()
  local prep = self._json.encode(self._data)
  love.filesystem.write(self._filename,prep)
end

return settings
