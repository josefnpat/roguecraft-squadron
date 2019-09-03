local scanlib = {}

local lerp = function(a,b,t) -- lerp value on speed of t
	return (1 - t) * a + t * b
end

function scanlib.load()
	scanlib.maxlineheight = 16
	scanlib.maxlife = 8
	scanlib.maxlines = 100

	scanlib.rspeed = 1 -- the higher the slower
	scanlib.gspeed = 2
	scanlib.bspeed = 3

	scanlib.effectsize = 4 -- the size of the color seperation

	scanlib.color = {}
	scanlib.color.r = 0.5
	scanlib.color.g = 1
	scanlib.color.b = 1

	scanlib.enabled = true

	scanlib.scanlines = {}
	for i = 1, scanlib.maxlines do
		local scanline = {}
		scanline.y = 0
		scanline.height = 0
		scanline.goal_y = math.random(love.graphics:getHeight() * 1.25)
		scanline.goal_height = math.random(scanlib.maxlineheight)
		scanline.age = 0
		scanline.life = scanlib.maxlife
		table.insert(scanlib.scanlines,scanline)
	end
end

function scanlib.scanstencil()
	for k,v in pairs(scanlib.scanlines) do
			love.graphics.rectangle("fill",0,v.y,love.graphics.getWidth(),v.height)
	end
end

function scanlib.toggle()
	if not scanlib.enabled then
		scanlib.enabled = true
		for k,v in pairs(scanlib.scanlines) do
			v.y = 0
		end
	else
		scanlib.enabled = false
		for k,v in pairs(scanlib.scanlines) do
			v.goal_y = 0
		end
	end

end

function scanlib.update(dt)
	for k,v in pairs(scanlib.scanlines) do
		v.age = v.age + dt
		if v.age > v.life and scanlib.enabled then
			v.age = 0
			v.life = math.random(scanlib.maxlife)
			v.goal_y = math.random(love.graphics:getHeight())
			v.goal_height = math.random(scanlib.maxlineheight)
		end
		v.y = lerp(v.y, v.goal_y, 0.01)
		v.height = lerp(v.height, v.goal_height, 0.01)
	end
end

function scanlib.draw(img,x,y,a,w,h,sx,sy)
	love.graphics.setColor(255,255,255)
	local rx_offset = math.cos(love.timer.getTime() / scanlib.rspeed)  * scanlib.effectsize
	local ry_offset = math.sin(love.timer.getTime() / scanlib.rspeed)  * scanlib.effectsize

	local gx_offset = math.sin(love.timer.getTime() / scanlib.gspeed)  * scanlib.effectsize
	local gy_offset = math.cos(love.timer.getTime() / scanlib.gspeed)  * scanlib.effectsize

	local bx_offset = math.cos(love.timer.getTime() / scanlib.bspeed)  * scanlib.effectsize
	local by_offset = math.sin(love.timer.getTime() / scanlib.bspeed)  * scanlib.effectsize
	local oldBlendMode = love.graphics.getBlendMode()
	love.graphics.setBlendMode("add")

	love.graphics.stencil(scanlib.scanstencil, "replace", 1)
	love.graphics.setStencilTest("greater", 0)

	love.graphics.setColor(scanlib.color.r*255,0,0)
	love.graphics.draw(img,x + rx_offset,y + ry_offset,a,w,h,sx,sy)
	love.graphics.setColor(0,scanlib.color.g*255,0)
	love.graphics.draw(img,x + gx_offset,y + gy_offset,a,w,h,sx,sy)
	love.graphics.setColor(0,0,scanlib.color.b*255)
	love.graphics.draw(img,x + bx_offset,y + by_offset,a,w,h,sx,sy)
	love.graphics.setBlendMode(oldBlendMode)
	love.graphics.setColor(255,255,255)
	love.graphics.setStencilTest()
end

return scanlib
