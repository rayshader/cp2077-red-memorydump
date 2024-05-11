---@class Controller
---@field signal Signal
local Controller = {}

---@param signal Signal | nil
function Controller:new(signal)
  local obj = {}
  setmetatable(obj, { __index = Controller })

  obj.signal = signal
  return obj
end

---@param controller string
---@param event string
---@param fn function
function Controller:Listen(controller, event, fn)
  self.signal:Listen(controller, event, fn)
end

---@param controller string
---@param event string
---@vararg any
function Controller:Emit(controller, event, ...)
  self.signal:Emit(controller, event, ...)
end

function Controller:Stop()
  --
end

return Controller
