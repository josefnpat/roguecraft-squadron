local net = {}

-- https://love2d.org/wiki/HSV_color
-- Converts HSV to RGB. (input and output range: 0 - 255)
function HSVToRGB(h, s, v)
    if s <= 0 then
      return v,v,v
    end
    h, s, v = h/256*6, s/255, v/255
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0,0,0
    if h < 1 then
      r,g,b = c,x,0
    elseif h < 2 then
      r,g,b = x,c,0
    elseif h < 3 then
      r,g,b = 0,c,x
    elseif h < 4 then
      r,g,b = 0,x,c
    elseif h < 5 then
      r,g,b = x,0,c
    else
      r,g,b = c,0,x
    end
    return (r+m)*255,(g+m)*255,(b+m)*255
end

local selected_alpha = 127

net._users = {}
local names = {"Alberto","Beryl","Chris","Debby","Ernesto","Florence","Gordon","Helene"}
for i,v in pairs(names) do
  local r,g,b = HSVToRGB(math.mod(i*0.618033988749895,1)*255,255,255)
  table.insert(net._users,{
    name = v,
    color = {r,g,b,selected_alpha},
    selected_color = {r,g,b},
  })
end

net._default = {
  name="Undefined",
  color={255,0,255,selected_alpha},
  selected_color={255,0,255},
}
net._neutral = {
  name="Neutral",
  color={255,255,0,selected_alpha},
  selected_color={255,255,0}
}

function net.getAngle(x1,y1,x2,y2)
  return math.atan2(y2-y1,x2-x1)
end

function net.getUser(index)
  return index and (net._users[index+1] or net._default) or net._neutral
end

function net.getCurrentLocation(object,time)
  local type = libs.objectrenderer.getType(object.type)
  if object.tdt and object.tx and object.ty then
    local dt = math.max(0,time - object.tdt)
    local distance = math.sqrt( (object.x-object.tx)^2 + (object.y-object.ty)^2 )
    local ratio = math.min(1,type.speed * dt / distance)
    local cx = (1-ratio)*object.x+ratio*object.tx
    local cy = (1-ratio)*object.y+ratio*object.ty
    return cx,cy
  else
    return object.x,object.y
  end
end

function net.distance(a,b,time)
  local ax,ay = net.getCurrentLocation(a,time)
  local bx,by = net.getCurrentLocation(b,time)
  return math.sqrt( (ax-bx)^2 + (ay-by)^2 )
end

return net
