local auxq = {}

function auxq.new(init)
  local self = {}
  self.all,self.clear = auxq.all,auxq.clear
  self.setQuery,self.setData = auxq.setQuery,auxq.setData
  self._query = init.query or function() return true end
  self._dirty = true
  return self
end

function auxq:all()
  if self._dirty then
    self._cache = {}
    self._dirty = false
    for i,v in pairs(self._data) do
      if self._query(self._data[i]) then
        self._cache[i] = v
      end
    end
  end
  return pairs(self._cache)
end

function auxq:setQuery(queryf)
  self:clear()
  self._query = queryf
end

function auxq:setData(d)
  self:clear()
  self._data = d
end

function auxq:clear()
  self._dirty = true
  self._data = {}
  self._cache = {}
end

return auxq
