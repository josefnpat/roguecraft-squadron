credits = {}

function credits:init()
	self.text = 
	"CREDITS:\n" ..
	"\n" ..
	"Ashley Hooper @ByteDesigning (Art)\n" ..
	"Josef Patoprsty @josefnpat (Code, Art, Design,Voice Talent)\n" ..
	"Mauricyo Furtado @eternalnightpro (Music,SFX)\n" ..
	"Arjan Vk (Vivid) (Code) \n" ..
	"Laura Vk (Solsforest) (Art,Voice Talent) \n" ..
	"\n" ..
	"Twitch Peeps:\n\n" ..
	"\n"
	
	for i = 1, 16 do
		self.text = self.text .. "Cool Person\n"
	end
	
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
	
	self.y = love.graphics:getHeight()
	self.scroll_speed = 8
end

function credits:update(dt)
	self.y = self.y - dt * self.scroll_speed
end

function credits:keypressed(key)
	libs.hump.gamestate.switch(states.menu)
end

function credits:draw()
	
	love.graphics.draw(self.space,0,0)

	love.graphics.setBlendMode("add")
	
	love.graphics.draw(self.stars0, self.stars0_quad,
    0,
    -self.stars0:getHeight()+((love.timer.getTime()*self.background_scroll_speed)%self.stars0:getHeight()) )

	love.graphics.draw(self.stars1, self.stars1_quad,
    0,
    -self.stars1:getHeight()+((love.timer.getTime()/2*self.background_scroll_speed)%self.stars1:getHeight()) )

	love.graphics.setBlendMode("alpha")
	
	love.graphics.printf(self.text,0,self.y,love.graphics:getWidth(),"center")
end

return credits