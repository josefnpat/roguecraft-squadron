local loading = {}

loading._dt = 0

function loading.draw(text)
  -- super lazy ...
  loading._camera = loading._camera or libs.picocam.new{}
  loading._camera.width = love.graphics.getWidth()
  loading._camera.height = love.graphics.getHeight()
  local old_font = love.graphics.getFont()
  local size = 0.1
  for i = -2,2,0.3 do
    loading._camera:line( {1*size,i,1*size}, {1*size,i,-1*size})
    loading._camera:line( {1*size,i,-1*size}, {-1*size,i,-1*size})
    loading._camera:line( {-1*size,i,-1*size}, {-1*size,i,1*size})
    loading._camera:line( {-1*size,i,1*size}, {1*size,i,1*size})
    size = size + 0.1
  end
  love.graphics.setFont(fonts.menu)
  dropshadowf(text,
    0,
    (love.graphics.getHeight()+fonts.menu:getHeight())/2,
    love.graphics.getWidth(),
    "center"
  )
  love.graphics.setFont(old_font)
end

function loading.update(dt)
  -- haha made this oop, ya jackass
  loading._camera = loading._camera or libs.picocam.new{}
  loading._dt = loading._dt + dt
  loading._camera.z = math.sin(loading._dt)/math.pi-4
  loading._camera.theta = loading._dt
end

return loading
