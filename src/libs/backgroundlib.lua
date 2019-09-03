local backgroundlib = {}

function backgroundlib.load()
  backgroundlib.default = love.graphics.newImage("assets/backgrounds/WP1_1080.png")
  backgroundlib.alt = love.graphics.newImage("assets/backgrounds/WP2_1080.png")
end

function backgroundlib.draw()
  backgroundlib._draw(backgroundlib.default)
end

function backgroundlib.drawAlt()
  backgroundlib._draw(backgroundlib.alt)
end

function backgroundlib._draw(image)
  local sx = love.graphics.getWidth()/image:getWidth()
  local sy = love.graphics.getHeight()/image:getHeight()
  love.graphics.draw(image,0,0,0,sx,sy)
end


return backgroundlib
