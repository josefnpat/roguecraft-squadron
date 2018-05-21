local server = {}

function server:init()
  self.lovernet = libs.lovernet.new{type=libs.lovernet.mode.server,serdes=libs.bitser}

  self.lovernet:addOp('git_count')
  self.lovernet:addProcessOnServer('git_count',function(self,peer,arg,storage)
    return git_count
  end)

  self.lovernet:addOp('user_count')
  self.lovernet:addProcessOnServer('user_count',function(self,peer,arg,storage)
    local count = 0
    for user_index,user in pairs(self:getUsers()) do
      count = count + 1
    end
    return count
  end)

  self.lovernet:addOp('debug_create_object')
  self.lovernet:addValidateOnServer('debug_create_object',{x='number',y='number'})
  self.lovernet:addProcessOnServer('debug_create_object',function(self,peer,arg,storage)
    local user = self:getUser(peer)
    storage.objects_index = storage.objects_index + 1
    local object = {
      index=storage.objects_index,
      x=arg.x,
      y=arg.y,
    }
    table.insert(storage.objects,object)
  end)

  self.lovernet:addOp('get_new_objects')
  self.lovernet:addValidateOnServer('get_new_objects',{index='number'})
  self.lovernet:addProcessOnServer('get_new_objects',function(self,peer,arg,storage)
    local objects = {}
    for _,object in pairs(storage.objects) do
      if object.index > arg.index then
        table.insert(objects,object)
      end
    end
    return objects
  end)

  self.lovernet:getStorage().objects = {}
  self.lovernet:getStorage().objects_index = 0

end

function server:update(dt)
  self.lovernet:update(dt)
end

function server:draw()
  str = ""
  str = str .. "objects: " .. #self.lovernet:getStorage().objects .. "\n"
  love.graphics.print(str)
end

return server
