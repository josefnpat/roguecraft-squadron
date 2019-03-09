local socket = require"socket"

local charset = {}
-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

local function randomstring(length)
  math.randomseed(socket.gettime()^5)
  if length > 0 then
    return randomstring(length - 1) .. charset[math.random(1, #charset)]
  else
    return ""
  end
end

return randomstring
