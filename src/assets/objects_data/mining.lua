return = function(parent)
  return {
    owner = parent.owner,
    type = "drydock",
    position = self:nearbyPosition(parent.position),
    size = 32,
    speed = 50,
    health = {
      max = 25,
    },
    death_sfx = self.objects_death_sfx.drydock,
    crew = self.costs.drydock.crew,
    ore = 400,
    material = 400,
    food = 100,
    food_gather = 10,
    repair = false,
    actions = {
      self.actions.salvage,
      self.actions.repair,
      self.actions.build_drydock,
      self.actions.build_mining,
      self.actions.build_refinery,
      self.actions.build_habitat,
      self.actions.build_combat,
      self.actions.build_cargo,
    }

  }
end
