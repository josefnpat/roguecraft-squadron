return {
  disabled = true,
  valid = function(object_type,user)
    return object_type.shoot ~= nil
  end,
  max_level = 5,
  cost = function(current)
    return 100+current*50
  end,
  value = function(current)
    return 1+current*0.1
  end,
}
