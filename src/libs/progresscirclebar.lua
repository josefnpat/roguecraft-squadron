local x,y,radius,radiuspercent,percent,start,stop

local function stencilf()
  love.graphics.circle("fill",x,y,radius*radiuspercent)
end

return function(ix,iy,r,rp,p,dt)
  --closures for fun and profit
  x,y,radius,radiuspercent,percent = ix,iy,r,rp,p
  start = (dt or 0)-math.pi/2
  stop = start + 2*math.pi*p

  love.graphics.stencil(stencilf,"increment")
  love.graphics.setStencilTest("less", 1)
  love.graphics.arc("fill",x,y,radius,start,stop)
  love.graphics.setStencilTest()
end
