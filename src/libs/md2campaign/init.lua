local md2campaign = {}

local open_quote = "\""
local close_quote = "\""

function md2campaign.new(init)
  init = init or {}
  local self = {}

  self.debug = md2campaign.debug
  self.getLevel = md2campaign.getLevel

  self._campaign = {
    title = "",
    levels = {},
  }

  self._assets = init.assets
  assert(self._assets)

  local c = 0 -- coverage
  local ct = 0 -- coverage total

  if init.data then

    local data_lines = {}
    for s in init.data:gmatch("[^\r\n]+") do
      table.insert(data_lines, s)
    end

    local level
    local last_name
    for _,s in pairs(data_lines) do
      ct = ct + 1

      if s:sub(1,2) == "# " then -- title
        c = c + 1
        self._campaign.title = s:sub(3)
      elseif s:sub(1) == "" then
        c = c + 1
        -- nop
      elseif s:sub(1,3) == "## " then -- mnew level
        c = c + 1
        if level ~= nil then
          table.insert(self._campaign.levels,level)
        end
        level = {
          name = s:sub(4),
          lines = {},
        }
        last_name = nil
      elseif s:sub(1,4) == "### " then -- mnew level
        c = c + 1
        table.insert(level.lines,{
          title = s:sub(5),
        })
      elseif s:sub(1,2) == "**" then
        c = c + 1
        --print("["..ct.."]: "..s)
        local name,text = s:match("%*%*(.+):%*%* (.+)")
        assert(name)
        assert(text)
        last_name = name
        table.insert(level.lines,{
          name=name,
          text=open_quote..text..close_quote,
        })
      elseif s:sub(1,2) == "--" then -- comment
        c = c + 1
        -- nop
      elseif last_name then
        c = c + 1
        table.insert(level.lines,{
          name=last_name,
          text=open_quote..s..close_quote,
        })
      else
        print("Unhandled line["..ct.."]: "..s)
      end
    end
    table.insert(self._campaign.levels,level)
  end

  -- calculate hashes
  self._campaign.hashes_name = {}
  self._campaign.hashes_text = {}
  for _,level in pairs(self._campaign.levels) do
    for _,line in pairs(level.lines) do

      if line.name then
        -- format names with [H|]display_name|name
        local name_split = line.name:split("|")
        if name_split[1] == "H" then
          table.remove(name_split,1)
          line.hologram = true
        end
        line.name = name_split[2] or name_split[1]
        line.display_name = name_split[1]

        line.hash_name = libs.md5.tohex(line.name)
        line.image_location = "/image/"..line.hash_name..".png"
        self._campaign.hashes_name[line.hash_name ] = line
      end

      if line.text then
        line.hash_text = libs.md5.tohex(line.text)
        line.audio_location = "/audio/"..line.hash_text..".ogg"
        self._campaign.hashes_text[line.hash_text] = line
        line.emote = line.text:match("%*(.+)*")
      end

    end
  end

  --check for images
  for _,line in pairs(self._campaign.hashes_name) do
    local file = self._assets .. line.image_location
    if not love.filesystem.isFile(file) then
      print("Warning: missing image for \""..line.name.."\" ["..file.."]")
    end
  end
  --check for audios
  for _,line in pairs(self._campaign.hashes_text) do
    local file = self._assets .. line.audio_location
    if not love.filesystem.isFile(file) then
      --print("Warning: missing audio for \""..line.text.."\" ["..file.."]")
    end
  end

  assert(c==ct)

  self._debug = {
    c = c,
    ct = ct,
  }

  return self
end

function md2campaign:debug()
  print("Campaign Coverage: "..self._debug.c.."/"..self._debug.ct)
  print("Title: "..self._campaign.title)
  for _,level in pairs(self._campaign.levels) do
    print("\tLevel Name:"..level.name)
    for _,line in pairs(level.lines) do
      print("\t\t["..line.name.."] "..line.text)
    end
  end
end

function md2campaign:getLevel(level_name)
  for _,level in pairs(self._campaign.levels) do
    if level.name == level_name then
      return level
    end
  end
  print("Warning: could not find level "..level_name)
end

return md2campaign
