local x,y,radius,radiuspercent,percent,start,stop

local function stencilf()
  love.graphics.arc("fill",x,y,radius*radiuspercent,start-0.05,stop+0.05)
end

return function(ix,iy,r,rp,p,dt)
  dt = dt or love.timer.getTime()

  --closures for fun and profit
  x,y,radius,radiuspercent,percent = ix,iy,r,rp,p
  start = -math.pi/2+dt
  stop = start + math.pi*2*p

  love.graphics.stencil(stencilf,"increment")
  love.graphics.setStencilTest("less", 1)
  love.graphics.arc("fill",x,y,radius,start,stop)
  love.graphics.setStencilTest()
end
