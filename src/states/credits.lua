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
	
	self.y = love.graphics:getHeight()
	self.scroll_speed = 8
end

function credits:update(dt)
	self.y = self.y - dt * self.scroll_speed
end

function credits:keypressed(key)

end

function credits:draw()
	love.graphics.printf(self.text,0,self.y,love.graphics:getWidth(),"center")
end

return credits