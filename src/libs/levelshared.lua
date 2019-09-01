local levelshared = {}

levelshared.team_2_and_3_defeated = function(storage,players)
  for _,object in pairs(storage.objects) do
    if object.user and not object.remove then
      if libs.net.isOnSameTeam(players,object.user,{team=2}) then
        return false
      end
      if libs.net.isOnSameTeam(players,object.user,{team=3}) then
        return false
      end
    end
  end
  return true
end

levelshared.gen = {}

levelshared.gen.getAllFirst = function()
  return {
    libs.levelshared.gen.demo().first,
    libs.levelshared.gen.human().first,
    libs.levelshared.gen.dojeer().first,
    libs.levelshared.gen.pirate().first,
    libs.levelshared.gen.alien().first,
  }
end

levelshared.gen.human = function()
  return {
    first = "command",
    default = {
      habitat=1,
      salvager=1,
    },
  }
end

levelshared.gen.dojeer = function()
  return {
    first = "dojeer_command",
    default = {
      dojeer_habitat=1,
      dojeer_salvager=1,
    },
  }
end

levelshared.gen.pirate = function()
  return {
    first = "pirate_command",
    default = {
      pirate_habitat=1,
      pirate_salvager=1,
    },
  }
end

levelshared.gen.alien = function()
  return {
    first = "alien_command",
    default = {
      alien_habitat=1,
      alien_salvager=1,
    },
  }
end

levelshared.gen.none = function()
  return {
    default = {},
  }
end

levelshared.gen.random = function()
  local random = math.random(4)
  if random == 1 then
    return levelshared.gen.human()
  elseif random == 2 then
    return levelshared.gen.dojeer()
  elseif random == 3 then
    return levelshared.gen.pirate()
  else -- random == 4
    return levelshared.gen.alien()
  end
end

levelshared.gen.demo = function()
  return {
    first = "command_demo",
    default = {
      habitat=1,
      salvager=1,
    },
  }
end

return levelshared
