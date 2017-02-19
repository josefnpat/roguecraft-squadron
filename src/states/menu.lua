local mainmenu = {}

function mainmenu:init()
	self.options = {}
	self.options[1] = {text = "New Game", act = function() libs.hump.gamestate.switch(states.game) end}
	self.options[2] = {text = "Credits", act = function() libs.hump.gamestate.switch(states.credits) end}
	self.options[3] = {text = "Exit", act = function() love.event.quit() end}
	
	self.space = love.graphics.newImage("space.png")
	
	self.stars0 = love.graphics.newImage("stars0.png")
	self.stars0:setWrap("repeat","repeat")
	self.stars0_quad = love.graphics.newQuad(0, 0,
	1280+self.stars0:getWidth(), 720+self.stars0:getHeight(),
		self.stars0:getWidth(), self.stars0:getHeight())
	
	self.stars1 = love.graphics.newImage("stars1.png")
	self.stars1:setWrap("repeat","repeat")
	self.stars1_quad = love.graphics.newQuad(0, 0,
    1280+self.stars1:getWidth(), 720+self.stars1:getHeight(),
		self.stars1:getWidth(), self.stars1:getHeight())
	
	self.background_scroll_speed = 4
	
	self.buttons_y = 1
end

function mainmenu:update(dt)
	self.buttons_y = love.graphics:getHeight() / 4
	if love.mouse.isDown(1) then
		self.buttonpressed = math.floor((love.mouse.getY() - self.buttons_y) / (fonts.menu:getHeight()))
		if self.options[self.buttonpressed] then
			self.options[self.buttonpressed].act()
		end		
	end
end

function mainmenu:keypressed(key)

end

function mainmenu:draw()
	love.graphics.setColor(255,255,255)
	
	love.graphics.draw(self.space,0,0)

	love.graphics.setBlendMode("add")
	
	love.graphics.draw(self.stars0, self.stars0_quad,
    -self.stars0:getWidth()+((love.timer.getTime()*self.background_scroll_speed)%self.stars0:getWidth()),
    -self.stars0:getHeight()+((love.timer.getTime()*self.background_scroll_speed)%self.stars0:getHeight()) )

	love.graphics.draw(self.stars1, self.stars1_quad,
    -self.stars1:getWidth()+((love.timer.getTime()/2*self.background_scroll_speed)%self.stars1:getWidth()),
    -self.stars1:getHeight()+((love.timer.getTime()/2*self.background_scroll_speed)%self.stars1:getHeight()) )

	love.graphics.setBlendMode("alpha")

	local y_offset = love.graphics:getHeight() * 0.075
	
	love.graphics.setFont(fonts.title)
	love.graphics.printf("Ultimate Space Rangers '95",0,y_offset + math.sin(love.timer.getTime()) * (y_offset / 4),love.graphics:getWidth(),"center")
	
	love.graphics.setFont(fonts.menu)
	for i = 1, #self.options do
		love.graphics.printf(self.options[i].text ,0,math.floor(self.buttons_y) + i * fonts.menu:getHeight( ),love.graphics:getWidth(),"center")
	end
end

return mainmenu