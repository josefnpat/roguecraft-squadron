local auxqlib = require"auxq"

tab = {
  {name="phil",hp=100},
  {name="george",hp=10},
  {name="bob",hp=0},
  {name="joe",hp=30},
  {name="red",hp=0},
  {name="sally",hp=50},
  {name="john",hp=0},
}

x = auxqlib.new{}

alive = function(a)
  return a.hp > 0
end

x:setData(tab)
x:addQuery("alive",alive)

print("\n>cached:",x:isCached("alive"))
for i,v in x:query("alive") do
  print(v.name.." is alive")
end

print("\n>cached:",x:isCached("alive"))
for i,v in x:query("alive") do
  print(v.name.." is alive")
end

x:clear()
print("\n>cached:",x:isCached("alive"))
for i,v in x:query("alive") do
  print(v.name.." is alive")
end
