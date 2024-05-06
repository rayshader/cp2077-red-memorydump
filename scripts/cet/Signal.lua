local Signal = {}

function Signal:new()
  local obj = {}
  setmetatable(obj, { __index = Signal })

  obj.listeners = {
    --[controller] = {
    --  [event]: {fn, ...}
    --}
  }
  return obj
end

function Signal:Listen(controller, event, fn)
  if self.listeners[controller] == nil then
    self.listeners[controller] = {}
  end
  local signal = self.listeners[controller]

  if signal[event] == nil then
    signal[event] = {}
  end
  local listener = signal[event]

  table.insert(listener, fn)
end

function Signal:Emit(controller, event, ...)
  local signal = self.listeners[controller]

  if signal == nil then
    return
  end
  local listener = signal[event]

  if listener == nil then
    return
  end
  for _, fn in ipairs(listener) do
    fn(...)
  end
end

return Signal
