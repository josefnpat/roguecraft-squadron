local enetfake = {}

function enetfake:connect()
end

local to_server = {}
local to_client = {}

function enetfake:peer_send_server(data)
  table.insert(to_client,data)
end

function enetfake:peer_send_client(data)
  table.insert(to_server,data)
end

local player = {name="fake_localhost"}

local peer_server = {
  send = enetfake.peer_send_server
}
local peer_client = {
  send = enetfake.peer_send_client
}

function enetfake:service_server()
  local event = {}
  if not self._connected then
    self._connected = true
    event.type = "connect"
    event.peer = peer_server
  else
    local data = table.remove(to_server, 1)
    event.type = "receive"
    event.data = data or {}
    event.peer = peer_server
  end
  -- self.type="disconnect"
  return event
end

function enetfake:service_client()
  local event = {}
  if not self._connected then
    self._connected = true
    event.type = "connect"
    event.peer = peer_client
  else
    local data = table.remove(to_client, 1)
    event.type = "receive"
    event.data = data or {}
    event.peer = peer_client
  end
  -- self.type="disconnect"
  return event
end

function enetfake.host_create(ip_port)
  local self = {}
  if ip_port then --server
    self.service=enetfake.service_server
  else -- client
    self.connect=enetfake.connect
    self.service=enetfake.service_client
  end
  return self,nil
end

return enetfake
