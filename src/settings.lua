settings = {}

settings.fullscreen = false
settings.muted = false

function settings:update()
	love.audio.stop()
	love.window.setFullscreen(settings.fullscreen,"exclusive")
end

return settings