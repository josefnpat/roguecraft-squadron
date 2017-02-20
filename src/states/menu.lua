local mainmenu = {}

function mainmenu:init()
  self.music = love.audio.newSource("assets/music/Terran4.ogg","stream")
  self.music:setVolume(0.75)
  playBGM(self.music)
end

function mainmenu:enter()
	self.options = {}
	self.options[1] = {text = "New Game", act = function() libs.hump.gamestate.switch(states.game); states.game:init() end}
	self.options[2] = {text = "Credits", act = function() libs.hump.gamestate.switch(states.credits) end}
	self.options[3] = {text = "Exit", act = function() love.event.quit() end}
	
	self.space = love.graphics.newImage("assets/space.png")
	
	self.stars0 = love.graphics.newImage("assets/stars0.png")
	self.stars0:setWrap("repeat","repeat")
	self.stars0_quad = love.graphics.newQuad(0, 0,
	1280+self.stars0:getWidth(), 720+self.stars0:getHeight(),
		self.stars0:getWidth(), self.stars0:getHeight())
	
	self.stars1 = love.graphics.newImage("assets/stars1.png")
	self.stars1:setWrap("repeat","repeat")
	self.stars1_quad = love.graphics.newQuad(0, 0,
    1280+self.stars1:getWidth(), 720+self.stars1:getHeight(),
		self.stars1:getWidth(), self.stars1:getHeight())
	
	self.background_scroll_speed = 4
	
	self.hover_sound = love.audio.newSource("assets/sfx/hover.wav")
	self.select_sound = love.audio.newSource("assets/sfx/select.wav")
	
	self.raw_planet_images = love.filesystem.getDirectoryItems("assets/planets/")
	self.planet_images = {}
	for i = 1, #self.raw_planet_images do
		self.planet_images[i] = love.graphics.newImage("assets/planets/" .. self.raw_planet_images[i])
	end
	self.random_planet = math.random(#self.planet_images)
	self.planet_rotation = 0.01
	
	self.buttons_y = 1
	
	self.input_delay_timer = 0
	self.input_delay_max = 0.1
end

function mainmenu:update(dt)
	self.input_delay_timer = self.input_delay_timer + dt
	self.buttons_y = love.graphics:getHeight() / 4
	self.hovered_button = math.floor((love.mouse.getY() - self.buttons_y) / (fonts.menu:getHeight()))
	if love.mouse.isDown(1) then
		self.buttonpressed = self.hovered_button
		if self.options[self.buttonpressed] then
			if self.input_delay_timer > self.input_delay_max then
				self.options[self.buttonpressed].act()
				playSFX(self.select_sound)
			end
		end		
	end
	
	if self.oldhovered_button ~= self.hovered_button and 
	self.hovered_button > 0 and 
	self.hovered_button <= #self.options then 
		playSFX(self.hover_sound)		
	end
	
	self.oldhovered_button = self.hovered_button
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
	
	love.graphics.draw(self.planet_images[self.random_planet],love.graphics:getWidth() * 0.1,love.graphics:getHeight() * 0.75,
		love.timer.getTime() * self.planet_rotation,1,1,
		self.planet_images[self.random_planet]:getWidth()/2,self.planet_images[self.random_planet]:getHeight()/2)

	local y_offset = love.graphics:getHeight() * 0.075
	
	love.graphics.setFont(fonts.title)
	dropshadowf(game_name,0,y_offset + math.sin(love.timer.getTime()) * (y_offset / 4),love.graphics:getWidth(),"center")
	
	love.graphics.setFont(fonts.menu)
	for i = 1, #self.options do
		local current_text = self.options[i].text
		if self.hovered_button == i then current_text = "[" .. current_text .. "]" end
		dropshadowf(current_text ,0,math.floor(self.buttons_y) + i * fonts.menu:getHeight( ),love.graphics:getWidth(),"center")
	end
	love.graphics.setFont(fonts.default)
  love.graphics.print("GIT v"..git_count.." ["..git_hash.."]",32,32)
end

return mainmenu
