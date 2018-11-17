local levelshared = {}

levelshared.team_2_or_3_defeated = function(storage,players)
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

return levelshared
