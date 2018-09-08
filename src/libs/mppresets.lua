local mppresets = {}

mppresets._presets = {}
mppresets._dir = "assets/mp_presets/"
for _,filename in pairs(love.filesystem.getDirectoryItems(mppresets._dir)) do
  local preset = require(mppresets._dir..file.name(filename))
  preset.id = fn
  table.insert(mppresets._presets,preset)
end

function mppresets.getPresets()
  return mppresets._presets
end

-- maybe this works?
function mppresets.getPreset(id)
  for _,preset in pairs(mppresets._presets) do
    if preset.id == id then
      return preset
    end
  end
end

return mppresets
