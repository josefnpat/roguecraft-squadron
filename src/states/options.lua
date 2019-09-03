local state = {}

function state:keypressed(key)
  if key == "escape" then
    libs.hump.gamestate.switch(states.menu)
  end
end

function state:update(dt)
  libs.options.menu:update(dt)
end

function state:draw()
  libs.backgroundlib.draw()
  libs.options.menu:draw()
end

return state
