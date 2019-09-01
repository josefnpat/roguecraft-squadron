local gettext = {}

local msgid_find = "^%s*msgid%s*\"(.*)\"%s*$"
local msgstr_find = "^%s*msgstr%s*\"(.*)\"%s*$"
local append_find = "^%s*\"(.*)\"%s*"
local MSGID,MSGSTR=0,1

local function wrap(s, w, pre)
  local sout = pre.."\""
  local x = string.len(sout)
  local y = 0
  for i = 1,string.len(s) do
    if x == 0 then
      sout = sout .. "\""
    end
    sout = sout .. string.sub(s,i,i)
    if x == w then
      sout = sout .. "\"\n\""
      x = 0
      y = y + 1
    end
    x = x + 1
  end
  return sout .. "\""
end

function gettext._decode(iterator)

  local msgid,msgstr
  local last

  local data = {}

  for line in iterator() do
    if last == MSGID then
      local _,_,test_append = line:find(append_find)
      if test_append then
        msgid = msgid .. test_append
      end
      local _,_,test_msgstr = line:find(msgstr_find)
      if test_msgstr then
        msgstr,last = test_msgstr,MSGSTR
      end
    elseif last == MSGSTR then
      local _,_,test_append = line:find(append_find)
      if test_append then
        msgstr = msgstr .. test_append
      end
      local _,_,test_msgid = line:find(msgid_find)
      if test_msgid then
        table.insert(data,{id=msgid,str=msgstr})
        msgid,msgstr,last = test_msgid,nil,MSGID
      end
    else -- first msgid
      local _,_,test_msgid = line:find(msgid_find)
      if test_msgid then
        msgid,last = test_msgid,MSGID
      end
    end
  end
  if msgid and msgstr then
    table.insert(data,{id=msgid,str=msgstr:gsub("\\n","\n")})
  end

  return data

end

function gettext.encode(data)
  local s = ""
  for i,v in pairs(data) do
    if v.comment then
      s = s .. "#. " .. v.comment .. "\n"
    end
    s = s .. wrap(v.id,80,"msgid ").."\n"
    s = s .. wrap(v.str,80,"msgstr ") .. (i==#data and "" or "\n\n")
  end
  return s
end

function gettext.decode(str)

  return gettext._decode(function() return str:gmatch("[^\r\n]+") end)

end

function gettext.decode_file(filename)

  local f = io.open(filename,"rb")
  local tmp = gettext._decode(function() return f:lines() end)
  f:close()

  return tmp

end

return gettext
