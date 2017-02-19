local mainmenu = {}

function mainmenu:init()
	self.options = {}
	self.options[1] = {text = "New Game", act = function() libs.hump.gamestate.switch(states.game) end}
	self.options[2] = {text = "Credits", act = function() libs.hump.gamestate.switch(states.credits) end}
	self.options[3] = {text = "Exit", act = function() love.event.quit() end}
	
	self.buttons_y = 1
end

function mainmenu:update(dt)
	self.buttons_y = love.graphics:getHeight() / 4
	if love.mouse.isDown(1) then
		self.buttonpressed = math.floor((love.mouse.getY() - self.buttons_y) / (fonts.default:getHeight()))
		if self.options[self.buttonpressed] then
			self.options[self.buttonpressed].act()
		end		
	end
end

function mainmenu:keypressed(key)

end

function mainmenu:draw()
	love.graphics.setColor(255,255,255)

	local y_offset = love.graphics:getHeight() * 0.075
	love.graphics.printf("Lovejam",0,y_offset + math.sin(love.timer.getTime()) * (y_offset / 4),love.graphics:getWidth(),"center")
	
	for i = 1, #self.options do
	
		love.graphics.printf(self.options[i].text ,0,math.floor(self.buttons_y) + i * fonts.default:getHeight( ),love.graphics:getWidth(),"center")
	end
end

return mainmenu