settings = {}

settings.fullscreen = false
settings.muted = false
settings.muted_music = false

function settings:update()
	playBGM(settings.bgm)
	love.window.setFullscreen(settings.fullscreen,"exclusive")
end

return settings