local net = {}

function net.getCurrentLocation(object,time)
  if object.tdt then
    local dt = math.max(0,time - object.tdt)
    local distance = math.sqrt( (object.x-object.tx)^2 + (object.y-object.ty)^2 )
    local ratio = math.min(1,object.speed * dt / distance)
    local cx = (1-ratio)*object.x+ratio*object.tx
    local cy = (1-ratio)*object.y+ratio*object.ty
    return cx,cy
  else
    return object.x,object.y
  end
end

return net
