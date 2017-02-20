settings = {}

settings.fullscreen = false
settings.muted = false
settings.muted_music = false
settings.volumes = {10,20,30,40,50,60,70,80,90,100}
settings.sound_volume = #settings.volumes
settings.music_volume = #settings.volumes

function settings:update()
	love.window.setFullscreen(settings.fullscreen,"exclusive")
	
	if settings.sound_volume > #settings.volumes then settings.sound_volume = 1 end
	if settings.music_volume > #settings.volumes then settings.music_volume = 1 end
	
	playBGM(settings.bgm)
end

return settings