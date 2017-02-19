local state = {}

require "settings"


function state:init()
	self.options = {}
	self.options[1] = {text = "Fullscreen", act = function() settings.fullscreen = not settings.fullscreen; settings.update() end}
	self.options[2] = {text = "Audio Mute", act = function() settings.muted = not settings.muted; settings.update() end}
	self.options[3] = {text = "Back", act = function() libs.hump.gamestate.switch(states.pause) end}
	
	self.hover_sound = love.audio.newSource("assets/sfx/hover.wav")
	self.select_sound = love.audio.newSource("assets/sfx/select.wav")
	
	self.buttons_y = 1
	
	self.input_delay_timer = 0
	self.input_delay_max = 0.1
end

function state:loadText()
	self.options[1].text = "Fullscreen:" .. tostring(settings.fullscreen)
	self.options[2].text = "Audio Mute: " .. tostring(settings.muted)
end

function state:update(dt)
	state:loadText()
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
		self.input_delay_timer = 0
	end
	
	if self.oldhovered_button ~= self.hovered_button and 
	self.hovered_button > 0 and 
	self.hovered_button <= #self.options then 
		playSFX(self.hover_sound)		
	end
	
	self.oldhovered_button = self.hovered_button
end

function state:keypressed(key)

end

function state:draw()
	love.graphics.setColor(255,255,255)
	
	states.game:draw()
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle("fill",0,0,love.graphics:getWidth(),love.graphics:getHeight())
	love.graphics.setColor(255,255,255)
	
	local y_offset = love.graphics:getHeight() * 0.075
	
	love.graphics.setFont(fonts.title)
	dropshadowf("[SETTINGS]",0,y_offset + math.sin(love.timer.getTime()) * (y_offset / 4),love.graphics:getWidth(),"center")
	
	love.graphics.setFont(fonts.menu)
	for i = 1, #self.options do
		local current_text = self.options[i].text
		if self.hovered_button == i then current_text = "[" .. current_text .. "]" end
		dropshadowf(current_text ,0,math.floor(self.buttons_y) + i * fonts.menu:getHeight( ),love.graphics:getWidth(),"center")
	end
	love.graphics.setFont(fonts.default)
end

return state