local tooltip = {}

function tooltip.set(val,ox,oy,ow,align)
  tooltip.data = {
    x=ox,
    y=oy,
    w=ow,
    align=align,
    val=val,
    dt = 0.1,
  }
end

function tooltip.draw()
  if tooltip.data then
    local str
    if type(tooltip.data.val) == "function" then
      str = tooltip.data.val(tooltip.data)
    elseif type(tooltip.data.val) == "string" then
      str = tooltip.data.val
    end
    if str then
      tooltipf(
        str,
        tooltip.data.x,
        tooltip.data.y,
        ow or 256,
        tooltip.data.align or "left")
    end
  end
end

function tooltip.update(dt)
  if tooltip.data then
    tooltip.data.dt = tooltip.data.dt - dt
    if tooltip.data.dt <= 0 then
      tooltip.data = nil
    end
  end
end

return tooltip
