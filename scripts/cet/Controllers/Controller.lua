local Controller = {}

function Controller:new(signal)
  local obj = {}
  setmetatable(obj, { __index = Controller })

  obj.signal = signal
  return obj
end

function Controller:Stop()
  --
end

return Controller
