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
    libs.levelshared.gen.alien().first,
    libs.levelshared.gen.dojeer().first,
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

levelshared.gen.alien = function()
  return {
    first = "alien_command",
    default = {
      alien_habitat=1,
      alien_salvager=1,
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

levelshared.gen.random = function()
  local random = math.random(3)
  if random == 1 then
    return levelshared.gen.human()
  elseif random == 2 then
    return levelshared.gen.alien()
  else -- random == 3
    return levelshared.gen.dojeer()
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
