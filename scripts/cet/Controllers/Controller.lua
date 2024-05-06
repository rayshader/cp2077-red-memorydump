local Controller = {}

function Controller:new(signal)
  local obj = {}
  setmetatable(obj, { __index = Controller })

  obj.signal = signal
  return obj
end

function Controller:Listen(controller, event, fn)
  self.signal:Listen(controller, event, fn)
end

function Controller:Emit(controller, event, ...)
  self.signal:Emit(controller, event, ...)
end

function Controller:Stop()
  --
end

return Controller
