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

---@param controller "dataViewer" | "memory" | "options" | "properties" | "targets"
---@param event string
---@param binding string?
function Controller:Listen(controller, event, binding)
  local obj = self

  if binding == nil then
    binding = event
  end
  self.signal:Listen(controller, event, function(...) obj[binding](obj, ...) end)
end

---@protected
---@param event string
---@vararg any
function Controller:Emit(event, ...)
  self.signal:Emit(self.name, "On" .. event, ...)
end

function Controller:Stop()
  --
end

return Controller
