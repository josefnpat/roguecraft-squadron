local gamestatus = {}

function gamestatus.new(init)
  init = init or {}
  local self = {}

  self.update = gamestatus.update
  self.startGame = gamestatus.startGame
  self.isStarted = gamestatus.isStarted
  self.isStartedTrigger = gamestatus.isStartedTrigger
  self.remainingPlayers = gamestatus.remainingPlayers
  self.remainingTeams = gamestatus.remainingTeams
  self.isPlayerAlive = gamestatus.isPlayerAlive
  self.isPlayerWin = gamestatus.isPlayerWin
  self.isPlayerLose = gamestatus.isPlayerLose
  self._checkCanWinLose = gamestatus._checkCanWinLose

  self._can_win_lose = false
  self._start_game = false

  return self
end

function gamestatus:update(dt,objects,players)

  self.counts = {}
  for _,object in pairs(objects) do
    if object.user then
      self.counts[object.user] = (self.counts[object.user] or 0) + 1
    end
  end

  self.teams = {}
  for player_index,player in pairs(players) do
    if self.counts[player_index-1] then
      self.teams[player.team] = (self.teams[player.team] or 0) + 1
    end
  end

end

function gamestatus:startGame()
  self._start_game = true
end

function gamestatus:isStarted()
  return self._start_game
end

function gamestatus:isStartedTrigger()
  local started = self._start_game and self._start_game_trigger == nil
  self._start_game_trigger = true
  return started
end

function gamestatus:remainingPlayers()
  local count = 0
  for _,player in pairs(self.counts) do
    count = count + 1
  end
  return count
end

function gamestatus:remainingTeams()
  local count = 0
  for _,player in pairs(self.teams) do
    count = count + 1
  end
  return count
end

function gamestatus:isPlayerAlive(user)
  return self.counts[user.id] ~= nil
end

function gamestatus:isPlayerWin(user)
  if self:_checkCanWinLose(user) then
    return self:remainingTeams() == 1 and self:isPlayerAlive(user)
  end
  return false
end

function gamestatus:isPlayerLose(user)
  if self:_checkCanWinLose(user) then
    return not self:isPlayerAlive(user)
  end
  return false
end

function gamestatus:_checkCanWinLose(user)
  if not self._can_win_lose then
    if self.counts[user.id] ~= nil and self.counts[user.id] > 0 and self:remainingTeams() > 1 then
      self._can_win_lose = true
    end
  end
  return self._can_win_lose
end

return gamestatus
