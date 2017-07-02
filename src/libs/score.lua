local score = {}

function score.new()
  local self = {}
  self._stats = {}
  self.define = score.define
  self.add = score.add
  self.render = score.render
  self.total = score.total
  return self
end

function score:define(name,string,q_sing,q_plur,svalue,init)
  self._stats[name] = {
    value = init or 0,
    svalue = svalue or 0,
    string = string,
    q = {
      sing = q_sing,
      plur = q_plur or q_sing,
    }
  }
end

function score:add(name,value)
  self._stats[name].value = self._stats[name].value + (value or 1)
end

function score:total()
  local s = 0
  for i,v in pairs(self._stats) do
    s = s + v.value*v.svalue
  end
  return s
end

function score:render()
  local t = {}
  for i,v in pairs(self._stats) do
    if math.floor(v.value) ~= 0 then
      table.insert(t,v.string.." "..math.floor(v.value).." "..(v.value == 1 and v.q.sing or v.q.plur))
    end
  end
  return table.concat(t,"\n").."\n\n"..libs.i18n('score.total',{score=math.floor(self:total())})
end

return score
