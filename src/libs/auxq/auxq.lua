--- auxq is an auxilary query system designed to cache queries on datasets
---- @module auxq
---- @author Josef N Patoprsty <josefnpat@gmail.com>
---- @copyright 2017
---- @license <a href="http://www.opensource.org/licenses/zlib-license.php">zlib/libpng</a>

local auxq = {
  _VERSION = "auxq v%%VERSION%%",
  _DESCRIPTION = "Auxilary query system designed to cache queries on datasets",
  _URL = "https://github.com/josefnpat/auxq/",
  _LICENSE = [[
    The zlib/libpng License
    Copyright (c) 2017 Josef N Patoprsty
    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.
    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:
    1. The origin of this software must not be misrepresented; you must not
       claim that you wrote the original software. If you use this software in a
       product, an acknowledgment in the product documentation would be
       appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be
       misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.
  ]]
}

---- Instansiate a new instance of auxq
-- @param init - A table with keys that would provide initial data (data)
-- @return a new instance of auxq
function auxq.new(init)
  init = init or {}
  local self = {}

  self._queries = {}

  self.query = auxq.query
  self.isCached = auxq.isCached
  self.addQuery = auxq.addQuery
  self.removeQuery = auxq.removeQuery
  self.setData = auxq.setData
  self.clear = auxq.clear

  self:setData(init.data or {})
  self:clear()

  return self
end

--- Get the pairs result of a named query
-- @param n (<i>Required</i>) - the name of the query
-- @return the cached pairs of named query
function auxq:query(n)
  assert(self._queries[n],"Query `"..tostring(n).."` does not exist.")
  if self._cache[n] == nil then
    self._cache[n] = {}
    for i,v in pairs(self._data) do
      if self._queries[n](v) then
        self._cache[n][i] = v
      end
    end
  end
  return pairs(self._cache[n])
end

--- Determine if a named query has been cached
-- @param n (<i>Required</i>) - the name of the query
-- @return A boolean if the named query has been cached
function auxq:isCached(n)
  assert(self._queries[n],"Query `"..tostring(n).."` does not exist.")
  return self._cache[n] ~= nil
end

--- Add a named query
-- @param n (<i>Required</i>) - the name of the query
-- @param f - the query in the form of a function
function auxq:addQuery(n,f)
  assert(self._queries[n]==nil,"Query `"..tostring(n).."` has already been set.")
  assert(type(f)=="function","Query is not a function.")
  self._queries[n] = f
end

--- Remove a named query
-- @param n (<i>Required</i>) - the name of the query
-- @return the named query
function auxq:removeQuery(n)
  assert(self._queries[n],"Query `"..tostring(n).."` does not exist.")
  local f = self._queries[n]
  self._queries[n] = nil
  return f
end

--- Set the data set
-- @param d (<i>Required</i>) - the data set as a table
function auxq:setData(d)
  assert(type(d)=="table","Data is not a table.")
  self._data = d
  self:clear()
end

--- Clear the entire cache or a specific query cache with a query name
-- @param n (<i>Optional</i>) - the name of the query
function auxq:clear(n)
  if n then
    assert(self._queries[n],"Query `"..tostring(n).."` does not exist.")
    self._cache[n] = nil
  else
    self._cache = {}
  end
end

return auxq
