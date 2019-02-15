local demosplash = {}

function demosplash.new(init)

  demosplash.image = demosplash.image or love.graphics.newImage("assets/demosplash.png")

  init = init or {}
  local self = {}

  self.update = demosplash.update
  self.draw = demosplash.draw

  self._buyButtonSteam = libs.button.new{
    text="Buy on Steam",
    icon=love.graphics.newImage("assets/steam.png"),
    onClick=function()
      love.system.openURL("https://store.steampowered.com/app/1000810/RogueCraft_Squadron/")
      love.event.quit()
    end,
  }

  self._buyButtonItchio = libs.button.new{
    text="Buy on Itch.io",
    icon=love.graphics.newImage("assets/itchio.png"),
    onClick=function()
      love.system.openURL("https://josefnpat.itch.io/roguecraft-squadron")
      love.event.quit()
    end,
  }

  self._quitButton = libs.button.new{
    text="No thanks, goodbye!",
    onClick=function()
      love.event.quit()
    end,
  }

  return self
end

function demosplash:update(dt)
  self._buyButtonSteam:update(dt)
  self._buyButtonItchio:update(dt)
  self._quitButton:update(dt)
end

function demosplash:draw()

  local ix = (love.graphics.getWidth()-demosplash.image:getWidth())/2
  local iy = (love.graphics.getHeight()-demosplash.image:getHeight())/2

  tooltipbg(ix-2,iy-2,demosplash.image:getWidth()+4,demosplash.image:getHeight()+4)
  love.graphics.setColor(255,255,255)
  love.graphics.draw(demosplash.image,ix,iy)

  self._buyButtonSteam:setX(ix+demosplash.image:getWidth()*3/8-self._buyButtonSteam:getWidth()/2)
  self._buyButtonItchio:setX(ix+demosplash.image:getWidth()*5/8-self._buyButtonItchio:getWidth()/2)
  self._quitButton:setX((love.graphics.getWidth()-self._quitButton:getWidth())/2)

  self._buyButtonSteam:setY(iy+demosplash.image:getHeight()*6.25/8)
  self._buyButtonItchio:setY(iy+demosplash.image:getHeight()*6.25/8)
  self._quitButton:setY(iy+demosplash.image:getHeight()*7/8)

  self._buyButtonSteam:draw(dt)
  self._buyButtonItchio:draw(dt)
  self._quitButton:draw(dt)

end


return demosplash
