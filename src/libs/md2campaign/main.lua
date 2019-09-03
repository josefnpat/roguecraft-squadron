local m = require('init')

local c = m.new{
  data=love.filesystem.read("script.md"),
}
c:debug()

love.event.quit()
