--local image = love.graphics.newImage("assets/loading.png")

return function (alpha)
  alpha = math.max(0,math.min(255,alpha))
  if alpha > 0 then
    local prev = {love.graphics.getColor()}
    love.graphics.setColor(0,0,0,alpha)
    love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
    --[[
    love.graphics.setColor(255,255,255,alpha)
    love.graphics.draw(
      image,
      (love.graphics.getWidth()-image:getWidth())/2,
      (love.graphics.getHeight()-image:getHeight())/2
    )
    --]]
    love.graphics.setColor(prev)
  end
end
