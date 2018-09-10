local buildqueue = {}

buildqueue.empty_img = love.graphics.newImage("assets/hud/icon_bg.png")

function buildqueue.new(init)
  init = init or {}
  local self = {}

  self.updateData = buildqueue.updateData
  self.update = buildqueue.update
  self.mouseInside = buildqueue.mouseInside
  self.runHoverAction = buildqueue.runHoverAction
  self.drawPanel = buildqueue.drawPanel
  self.add = buildqueue.add

  self._width = init.width or 192
  self.setWidth = buildqueue.setWidth
  self.getWidth = buildqueue.getWidth

  self.getHeight = buildqueue.getHeight

  self._x = init.x or 32
  self.setX = buildqueue.setX
  self.getX = buildqueue.getX
  self._y = init.y or 32
  self.setY = buildqueue.setY
  self.getY = buildqueue.getY

  self._coff = 16 -- center offset

  self.doFullUpdate = buildqueue.doFullUpdate
  self._doFullUpdate = true

  self.progress = libs.bar.new{
    text = "0%",
    hoverText = "Build Queue",
    width = self._width,
    icon = buildqueue.empty_img,
    barValue = 0.0,
    drawbg = false,
  }

  self.queue = libs.matrixpanel.new{
    width=192,
    padding=1,
    drawbg = false,
  }

  self.data = {}

  return self
end

function buildqueue:updateData(object,resources)

  if object.build_dt and object.build_t then
    local percent = 1-object.build_dt/object.build_t
    self.progress:setBarValue(percent)
    self.progress:setText(math.floor(percent*100).."%")
    self.progress:setHoverText( math.floor(object.build_dt*10)/10 .. "s")
  else
    self.progress:setBarValue(0)
    self.progress:setText("Ready")
    self.progress:setHoverText("Queue Empty")
  end

  if object.build_current then
    self.progress:setIcon(object.build_current.icons[1])
  else
    self.progress:setIcon(buildqueue.empty_img)
  end

  if self._doFullUpdate then
    self._doFullUpdate = false

    self.queue:clearActions()
    for qobject_index,qdata in pairs(object.queue) do

      local qobject_type = qdata.type

      local canAfford = true
      if #object.queue > 0 then
        canAfford = resources:canAfford(qobject_type)
      end

      self.queue:addAction(
        qobject_type.icons[1],
        function(cobject)
          table.remove(object.queue,qobject_index)
          self:doFullUpdate()
        end,
        function(hover)
          local alpha = hover and 255 or 191
          return canAfford and {0,255,0,alpha} or {255,0,0,alpha}
        end,
        function()
          local name = qobject_type.loc.name
          return "Cancel "..name
        end
      )

    end

    for i = #object.queue+1,5 do
      self.queue:addAction(
        buildqueue.empty_img,
        function(cobject)
        end,
        function(hover)
          return {255,255,255,hover and 255 or 191}
        end,
        function()
          return "Empty"
        end
      )
    end

  end -- self._doFullUpdate

end

function buildqueue:update(dt,user,objects,resources,lovernet)
  self.progress:update(dt)
  self.progress:setX(self._x)
  self.progress:setY(self._y)

  self.queue:update(dt)
  self.queue:setX(self._x)
  self.queue:setY(self._y+self.progress:getHeight()-self._coff)

  for _,object in pairs(objects) do

    if object.user == user.id and #object.queue > 0 and object.build_current == nil then --and object.build_dt == nil and object.build_t == nil then
      local qobject = object.queue[1].type
      local qobject_type = libs.objectrenderer.getType(qobject.type)
      if resources:canAfford(qobject_type) then
        libs.sfx.loop("action.build.start")
        lovernet:pushData(libs.net.op.action,{
          a=object.queue[1].action,
          t={object.index},
        })
        object.build_current = object.queue[1].type
        assert(object.build_current)
        table.remove(object.queue,1)
        self:doFullUpdate()
      else
        resources:cantAffordNotif(qobject_type)
      end
    end
  end

end

function buildqueue:mouseInside(x,y)
  x = x or love.mouse.getX()
  y = y or love.mouse.getY()
  return self.progress:mouseInside(x,y) or self.queue:mouseInside(x,y)
end

function buildqueue:runHoverAction()
  if self.progress:mouseInside() then
    -- todo: cancel current queue?
  end
  if self.queue:mouseInside() then
    self.queue:runHoverAction()
  end
end

function buildqueue:drawPanel()
  tooltipbg(self._x,self._y,self._width,self:getHeight())
  self.progress:draw()
  self.queue:draw()
  if debug_mode then
    love.graphics.rectangle("line",self._x,self._y,self._width,self:getHeight())
  end
end

function buildqueue:add(object,object_type,action)
  if #object.queue < 5 then
    table.insert(object.queue,{type=object_type,action=action})
    self:doFullUpdate()
  end
end

function buildqueue:setWidth(val)
  self._width = val
end

function buildqueue:getWidth()
  return self._width
end

function buildqueue:getHeight()
  return self.progress:getHeight()+self.queue:getHeight()-self._coff
end

function buildqueue:setX(val)
  self._x = val
end

function buildqueue:getX()
  return self._x
end

function buildqueue:setY(val)
  self._y = val
end

function buildqueue:getY(val)
  return self._y
end

function buildqueue:doFullUpdate()
  self._doFullUpdate = true
end

return buildqueue
