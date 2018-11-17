local sfx = {}

function sfx.parseDir(parse_dir,group)
  for _,sfx_dir in pairs(love.filesystem.getDirectoryItems(parse_dir)) do
    for _,sub_sfx in pairs(love.filesystem.getDirectoryItems(parse_dir..sfx_dir)) do
      sfx.add(sfx_dir,parse_dir..sfx_dir.."/"..sub_sfx,group)
    end
  end
end

function sfx.load()
  sfx._data = {}
  sfx.parseDir("assets/mp_vo/","vo")
  sfx.parseDir("assets/mp_sfx/")
end

function sfx.add(name,fsloc,group)
  fsloc = fsloc or name
  sfx._data[name] = sfx._data[name] or {sources={}}
  sfx._data[name].group = group
  table.insert(sfx._data[name].sources,love.audio.newSource(fsloc,"static"))
end

function sfx.get(name)
  return sfx._data[name].sources[math.random(#sfx._data[name].sources)]
end

function sfx.mute(val)
  assert(type(val)=="boolean")
  sfx._mute = val
end

function sfx.play(name,variation)
  for _,v in pairs(sfx._data[name].sources) do
    v:stop()
  end
  sfx.playVariation(name,variation)
end

function sfx.loop(name,variation)
  local is_playing = false
  for _,source in pairs(sfx._data[name].sources) do
    if source:isPlaying( ) then
      is_playing = true
    end
  end
  if not is_playing then
    sfx.playVariation(name,variation)
  else
    sfx.skipWarning(name)
  end
end

function sfx.loopGroup(name,variation)
  local is_playing = false
  local current_data = sfx._data[name]
  for _,data in pairs(sfx._data) do
    if data.group == current_data.group then
      for _,source in pairs(data.sources) do
        if source:isPlaying( ) then
          is_playing = true
        end
      end
    end
  end
  if not is_playing then
    sfx.playVariation(name,variation)
  else
    sfx.skipWarning(name)
  end
end

function sfx.playVariation(name,variation)
  if not sfx._mute then
    local current_source = sfx._data[name].sources[math.random(#sfx._data[name].sources)]
    if sfx._data[name].group == "vo" then
      current_source:setVolume(settings:read("voiceover_vol"))
    else
      current_source:setVolume(settings:read("sfx_vol"))
    end
    if variation then
      current_source:setPitch( (1-variation)+math.random()*variation*2 )
    else
      current_source:setPitch(1)
    end
    love.audio.play(current_source)
  end
end

function sfx.skipWarning(name)
end

return sfx
