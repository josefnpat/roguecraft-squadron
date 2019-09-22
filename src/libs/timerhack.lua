local _getTime = love.timer.getTime
local paused = false
local offset = 0

function love.timer.getTime()
  return _getTime()-offset
end

function love.timer.setPause(val)
  paused = val
end

function love.timer.isPaused()
  return paused
end

function love.timer.update(dt)
  if paused then
    offset = offset + dt
  end
end
