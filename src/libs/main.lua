local auxqlib = require"auxq"

tab = {
  {cool="hello"},
  {cool="world"},
  {},
}

x = auxqlib.new{}

cool = function(a)
  return a.cool
end

x:setQuery(cool)
x:setData(tab)

for i,v in x:all() do
  print(v.cool)
end

love.event.quit()
