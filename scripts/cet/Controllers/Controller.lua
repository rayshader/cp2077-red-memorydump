---@class Controller
---@field private name string
---@field private signal Signal
---@field private intervals table<string, number>
local Controller = {}

---@param name string
---@param signal Signal | nil
function Controller:new(name, signal)
  local obj = {}
  setmetatable(obj, { __index = Controller })

  obj.name = name
  obj.signal = signal
  obj.intervals = {}
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

---@param interval number
---@param event string
function Controller:StartInterval(interval, event)
  local obj = self
  local id = self.intervals[event]

  if id ~= nil then
    self.signal:UnregisterInterval(id)
  end
  self.intervals[event] = self.signal:RegisterInterval(interval, function() obj[event](obj) end)
end

---@param event string
function Controller:StopInterval(event)
  local id = self.intervals[event]

  if id == nil then
    return
  end
  self.signal:UnregisterInterval(id)
  self.intervals[event] = nil
end

function Controller:Stop()
  --
end

return Controller
