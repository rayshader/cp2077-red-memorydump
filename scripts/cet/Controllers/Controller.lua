---@class Controller
---@field name string
---@field signal Signal
local Controller = {}

---@param name string
---@param signal Signal | nil
function Controller:new(name, signal)
  local obj = {}
  setmetatable(obj, { __index = Controller })

  obj.name = name
  obj.signal = signal
  return obj
end

function Controller:Load()
end

---@param controller string
---@param event string
---@param fn function
function Controller:Listen(controller, event, fn)
  self.signal:Listen(controller, event, fn)
end

---@protected
---@param event string
---@vararg any
function Controller:Emit(event, ...)
  self.signal:Emit(self.name, event, ...)
end

function Controller:Stop()
  --
end

return Controller
