local net = {}

net.next_level_t = 5
net.max_players = 8

function net.clearCache()
  net.cache = {
    getCurrentLocation = {},
    objectShouldBeRemoved = {},
  }
end
net.clearCache()

net.op = {
  git_count =           'g',
  user_count =          'n',
  get_user =            'u',
  get_config =          'f',
  set_config =          'h',
  get_level =           'e',
  get_players =         'i',
  set_players =         'j',
  get_research =        'z',
  set_research =        'x', --10
  debug =               'c',
  delete_objects =      'd',
  get_new_objects =     'o',
  get_new_updates =     'p',
  get_new_bullets =     'b',
  move_objects =        'm',
  target_objects =      'y',
  get_resources =       'r',
  get_points =          'q',
  time =                't', --20
  action =              'a',
  add_chat =            'k',
  get_chat =            'l',
}

net.resourceTypes = {"ore","material","crew","research"}

net.classTypes = {
  military="Military",
  construction="Construction",
  industrial="Industrial",
  support="Support",
}

net.mapGenDefaults = {
  {
    text = "Normal",
    value = {
      scrap=100,
      station=16,
      research_station=8,
      asteroid=50,
      cat=1,
      cloud=16,
      mw_scout=16,
      mw_fighter=8,
      mw_combat=4,
    },
  },
  {
    text = "Heavy",
    value = {
      scrap=200,
      station=32,
      research_station=16,
      asteroid=100,
      cat=1,
      cloud=16,
      mw_scout=32,
      mw_fighter=16,
      mw_combat=8,
    },
  },
  {
    text = "Light",
    value = {
      scrap=50,
      station=8,
      research_station=4,
      asteroid=25,
      cat=1,
      cloud=16,
      mw_scout=8,
      mw_fighter=4,
      mw_combat=2,
    },
  },
}

net.mapSizes = {
  {
    text = "Medium — 6K",
    value = 32*64*3/2,
  },
  {
    text = "Large — 8K",
    value = 32*64*4/2,
  },
  {
    text = "Huge — 10K",
    value = 32*64*5/2,
  },
  {
    text = "Enormous — 12K",
    value = 32*64*6/2,
  },
  { -- survival gamemode depends on this being #5
    text = "Tiny — 2K",
    value = 32*64*1/2,
  },
  {
    text = "Small — 4k",
    value = 32*64*2/2,
  },
}

-- todo: i18n
net.resourceStrings = {
  ore="Ore",
  material="Material",
  crew="Crew",
  research="Research",
}

net.aiDifficultyBase = 20
net.aiDifficultyScale = 50

-- do not change this order unless you update the gamemodes
net.race = {
  {
    name="Human",
    tooltip="Humans represent the finest in humanity.",
    gen="human",
  },
  {
    name="Dojeer",
    tooltip="A race of hivemind plant based creatures featured in the Campaign. Warning: the Dojeer language has not been translated.",
    gen="dojeer",
  },
  {
    name="Pirate",
    tooltip="Pirates represent the worst in humanity.",
    gen="pirate",
  },
  {
    name="Hybrid",
    tooltip="A race of aliens featured in the original love gamejam.",
    gen="alien",
  },
  {
    name="Random",
    tooltip="A random race will be selected.",
    gen="random",
  },
}

-- gamemodes depend on this being 6 elements
net.aiDifficulty = {
  {
    roman_numeral = "I",
    text = "Fg Off (I)",
    full_text = "Flying Officer",
    apm = function() return net.aiDifficultyBase+net.aiDifficultyScale*0 end,
  },
  {
    roman_numeral = "II",
    text = "Flt Lt (II)",
    full_text = "Flight Lieutenant",
    apm = function() return net.aiDifficultyBase+net.aiDifficultyScale*1 end,
  },
  {
    roman_numeral = "III",
    text = "Sqn Ldr (III)",
    full_text = "Squadron Leader",
    apm = function() return net.aiDifficultyBase+net.aiDifficultyScale*2 end,
  },
  {
    roman_numeral = "IV",
    text = "Wg Cdr (IV)",
    full_text = "Wing Commander",
    apm = function() return net.aiDifficultyBase+net.aiDifficultyScale*3 end,
  },
  {
    roman_numeral = "V",
    text = "Gp Capt (V)",
    full_text = "Group Captain",
    apm = function() return net.aiDifficultyBase+net.aiDifficultyScale*4 end,
  },
  {
    roman_numeral = "VI",
    text = "Air Cdre (VI)",
    full_text = "Air Commodore",
    apm = function() return net.aiDifficultyBase+net.aiDifficultyScale*5 end,
  },
}

net.maps = {
  {
    text = "Spaced Pockets",
    value = "spacedpockets",
  },
  {
    text = "Random",
    value = "random",
  },
}

-- Command Capacity
net.points = {
  {
    text = "Medium — 600",
    value = 600,
  },
  {
    text = "High — 1000",
    value = 1000,
  },
  {
    text = "Infinite — ∞",
    value = math.huge,
  },
  {
    text = "Minimal — 100",
    value = 100,
  },
  {
    text = "Normal — 200",
    value = 200,
  },
}

net.transmitRates = {
  {
    text = "High — 62.5ms",
    value = 1/16
  },
  {
    text = "Medium — 125ms",
    value = 1/8,
  },
  {
    text = "Low — 250ms",
    value = 1/4,
  },
  {
    text = "Excessive — 15.6ms",
    value = 1/64,
  },
  {
    text = "V High — 31.3ms",
    value = 1/32,
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

local colors = {}

-- first four are good for deut
-- last two are not, but that's why they're at the end
colors.default = {
  text = "Default",
  data = {
    {77,175,74},
    {152,78,163},
    {255,255,51},
    {247,129,191},
    {255,127,0},
    {55,126,184},
    {228,26,28},
    {166,86,40},
  }
}

net._users = {}
for i = 1,8 do
  local r,g,b = unpack(colors.default.data[i])
  table.insert(net._users,{
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
  if net.cache.getCurrentLocation[object] == nil then
    local type = libs.objectrenderer.getType(object.type)
    if object.tdt and object.tx and object.ty then
      local dt = math.max(0,time - object.tdt)
      local distance = math.sqrt( (object.x-object.tx)^2 + (object.y-object.ty)^2 )
      local ratio = math.min(1,(type.speed or 0)* dt / distance)
      local cx = (1-ratio)*object.x+ratio*object.tx
      local cy = (1-ratio)*object.y+ratio*object.ty
      net.cache.getCurrentLocation[object] = {x=round(cx),y=round(cy)}
    else
      net.cache.getCurrentLocation[object] = {x=round(object.x),y=round(object.y)}
    end
  end
  return net.cache.getCurrentLocation[object].x, net.cache.getCurrentLocation[object].y
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
  return net.hasMoveTarget(object,time)
end

function net.hasMoveTarget(object,time)
  local cx,cy = net.getCurrentLocation(object,time)
  if (object.tx ~= nil and object.ty ~= nil) and (cx ~= round(object.tx) or cy ~= round(object.ty)) then
    return true
  end
  return false
end

function net.moveToTarget(server,object,x,y,int)
  local storage = server.lovernet:getStorage()
  local mapsize = libs.net.mapSizes[storage.config.mapsize].value
  local type = libs.objectrenderer.getType(object.type)
  if type.speed then
    local cx,cy = server:stopObject(object)
    object.tx = math.min(math.max(-mapsize,x),mapsize)
    object.ty = math.min(math.max(-mapsize,y),mapsize)
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

function net._objectShouldBeRemoved(object)
  if object.remove or object.remove_no_drop then
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

function net.objectShouldBeRemoved(object)
  if net.cache.objectShouldBeRemoved[object] == nil then
    net.cache.objectShouldBeRemoved[object] = net._objectShouldBeRemoved(object)
  end
  return net.cache.objectShouldBeRemoved[object]
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
  assert(#players>0)
  if type(a) == "number" then
    for i,v in pairs(players) do
      if i == a + 1 then
        return v
      end
    end
    return nil
  end
  return a
end

function net.isOnSameTeam(players,a,b)
  if a == nil then return false end
  if b == nil then return false end
  local user_a = net.getPlayersAbstract(players,a)
  local user_b = net.getPlayersAbstract(players,b)
  if user_a == nil then
    print('warning: player[a] "'..a..'" does not exist')
    return false
  end
  if user_b == nil then
    print('warning: player[b] "'..b..'" does not exist')
    return false
  end
  assert(user_a.team)
  assert(user_b.team)
  return user_a.team == user_b.team
end

return net
