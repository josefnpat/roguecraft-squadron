local net = {}

net.op = {
  git_count =           'g',
  user_count =          'n',
  get_user =            'u',
  get_config =          'f',
  set_config =          'h',
  get_players =         'i',
  set_players =         'j',
  get_research =        'z',
  set_research =        'x',
  debug_create_object = 'c',
  delete_objects =      'd',
  get_new_objects =     'o',
  get_new_updates =     'p',
  get_new_bullets =     'b',
  move_objects =        'm',
  target_objects =      'y',
  get_resources =       'r',
  get_points =          'q',
  time =                't',
  action =              'a',
  add_chat =            'k',
  get_chat =            'l',
}
net.resourceTypes = {"ore","material","crew"}
net.mapsize = 32*192/2

-- todo: i18n
net.resourceStrings = {
  ore="Ore",
  material="Material",
  crew="Crew",
}

net.aiDifficultyBase = 20
net.aiDifficultyScale = 50

net.aiDifficulty = {
  {
    text = "Chew Toy",
    apm = function() return net.aiDifficultyBase+net.aiDifficultyScale*0 end,
  },
  {
    text = "Scrub",
    apm = function() return net.aiDifficultyBase+net.aiDifficultyScale*1 end,
  },
  {
    text = "Awkward",
    apm = function() return net.aiDifficultyBase+net.aiDifficultyScale*2 end,
  },
  {
    text = "Bananas",
    apm = function() return net.aiDifficultyBase+net.aiDifficultyScale*3 end,
  },
  {
    text = "Ragequit",
    apm = function() return net.aiDifficultyBase+net.aiDifficultyScale*4 end,
  },
  {
    text = "No Ice Cream",
    apm = function() return net.aiDifficultyBase+net.aiDifficultyScale*5 end,
  },
}

-- Command Capacity
net.points = {
  {
    text = "Low (200)",
    value = 200,
  },
  {
    text = "Medium (600)",
    value = 600,
  },
  {
    text = "High (1000)",
    value = 1000,
  },
  {
    text = "Infinite (∞)",
    value = math.huge,
  },
}

function net.hasPoints(pointsValue,points,object_type)
  return pointsValue + (object_type.points or 1) <= libs.net.points[points].value
end

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
local full_offset = -0.2
for i,v in pairs(names) do
  local scalar = 1/8
  local offset = i%2==0 and full_offset or full_offset+0.5
  local r,g,b = HSVToRGB(math.mod(i*scalar+offset,1)*255,255,255)
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

function net.shortestAngle(c,t)
  return (t-c+math.pi)%(math.pi*2)-math.pi
end

function net.getCurrentLocation(object,time)
  time = time or love.timer.getTime()
  local type = libs.objectrenderer.getType(object.type)
  if object.tdt and object.tx and object.ty then
    local dt = math.max(0,time - object.tdt)
    local distance = math.sqrt( (object.x-object.tx)^2 + (object.y-object.ty)^2 )
    local ratio = math.min(1,(type.speed or 0)* dt / distance)
    local cx = (1-ratio)*object.x+ratio*object.tx
    local cy = (1-ratio)*object.y+ratio*object.ty
    return round(cx),round(cy)
  else
    return round(object.x),round(object.y)
  end
end

function net.findObject(objects,index)
  for _,object in pairs(objects) do
    if object.index == index then
      return object
    end
  end
end

function net.hasUserObjects(objects)
  for _,object in pairs(objects) do
    if object.user then
      return true
    end
  end
  return false
end

function net.hasTarget(object,time)
  time = time or love.timer.getTime()
  if object.target ~= nil then
    return true
  end
  if object.tint then
    return false
  end
  local cx,cy = net.getCurrentLocation(object,time)
  if (object.tx ~= nil and object.ty ~= nil) and (cx ~= round(object.tx) or cy ~= round(object.ty)) then
    return true
  end
  return false
end

function net.moveToTarget(server,object,x,y,int)
  local type = libs.objectrenderer.getType(object.type)
  if type.speed then
    local cx,cy = server:stopObject(object)
    object.tx = math.min(math.max(-libs.net.mapsize,x),libs.net.mapsize)
    object.ty = math.min(math.max(-libs.net.mapsize,y),libs.net.mapsize)
    object.tdt = love.timer.getTime()
    object.target = nil
    object.tint = int
    local update={
      tx = round(object.tx),
      ty = round(object.ty),
      tdt = round(object.tdt,2),
      target = "nil",
    }
    if cx and cy then
      update.x,update.y = cx,cy
    end
    server:addUpdate(object,update,"move_objects")
  end
end

function net.setObjectTarget(server,object,target)
  object.target = target
  server:addUpdate(object,{
    target = target,
  },"target_objects")
end

function net.build(server,user,parent,action)
  if parent and parent.user == user.id then
    if server.actions[action] then
      server.actions[action](user,parent)
    end
  end
end

function net.getObjectByIndex(objects,index)
  for _,object in pairs(objects) do
    if object.index == index then
      return object
    end
  end
end

function net.objectShouldBeRemoved(object)
  if object.remove then
    return true
  end
  if object.health and object.health <= 0 then
    return true
  end
  for _,restype in pairs(libs.net.resourceTypes) do
    local supply_str = restype.."_supply"
    if object[supply_str] and object[supply_str] <= 0 then
      return true
    end
  end
  return false
end

function net.getCurrentBulletLocation(bullet,target,time)
  local ctime = time - bullet.tdt
  local ratio = math.min(1,ctime/bullet.eta)

  local ctx,cty = net.getCurrentLocation(target,time)

  local cbx = (1-ratio)*bullet.x+ratio*ctx
  local cby = (1-ratio)*bullet.y+ratio*cty
  return cbx,cby,ctx,cty
end

function net.distance(a,b,time)
  local ax,ay = net.getCurrentLocation(a,time)
  local bx,by = net.getCurrentLocation(b,time)
  return math.sqrt( (ax-bx)^2 + (ay-by)^2 )
end

function net.getPlayerId(users,user)
  for player_index,player in pairs(users) do
    if user.id == player.id then
      return player_index
    end
  end
end

function net.getPlayerById(users,id)
  for _,player in pairs(users) do
    if id == player.id then
      return player
    end
  end
end

function net.getPlayerByAi(users,ai)
  for _,player in pairs(users) do
    if ai == player.config.ai then
      return player
    end
  end
end

function net.userOwnsObject(user,object)
  return object.user == user.id
end

function net.getPlayersAbstract(players,a)
  if type(a) == "number" then
    for i,v in pairs(players) do
      if i == a + 1 then
        return v
      end
    end
  end
  return a
end

function net.isOnSameTeam(players,a,b)
  if a == nil then return false end
  if b == nil then return false end
  local user_a = net.getPlayersAbstract(players,a)
  local user_b = net.getPlayersAbstract(players,b)
  assert(user_a.team)
  assert(user_b.team)
  return user_a.team == user_b.team
end

return net
