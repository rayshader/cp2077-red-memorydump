local Utils = require_verbose("Utils")

---@class Controller
---@field private _name string
---@field private _signal Signal
---@field private _intervals table<string, number>
---@field private _fields string[]
---@field private _bindings any[]
---@field private _states any
local Controller = {}

---@param name string
---@param signal Signal | nil
function Controller:new(name, signal)
  local obj = {}
  setmetatable(obj, { __index = Controller })

  obj._name = name
  obj._signal = signal
  obj._intervals = {}
  -- Cache fields of ViewModel. It must be defined in controller's 
  -- constructor. Don't use `nil` to declare a field, it won't be bound!
  obj._fields = {}
  -- List to transform controller's method into view's field, readonly.
  obj._bindings = {}
  -- Cache of ViewModel since last Controller:Update() call. Data is populated
  -- in View as readonly fields, during Controller:Attach() call.
  obj._states = {}
  return obj
end

---@return string
function Controller:GetName()
  return self._name
end

function Controller:Load()
  for field, _ in pairs(self) do
    if not field:find("^_") then
      table.insert(self._fields, field)
    end
  end
end

---@param fn string
---@vararg any
function Controller:Queue(fn, ...)
  self._signal:Queue(self, fn, ...)
end

function Controller:Update()
  for _, field in ipairs(self._fields) do
    self._states[field] = Utils.clone(self[field])
  end
  for _, binding in ipairs(self._bindings) do
    self._states[binding.field] = self[binding.fn](self)
  end
end

---@param view View
function Controller:Attach(view)
  for _, field in ipairs(self._fields) do
    view[field] = self._states[field]
  end
  for _, binding in ipairs(self._bindings) do
    view[binding.field] = self._states[binding.field]
  end
end

---@param controller "hotkey" | "dataViewer" | "memory" | "options" | "properties" | "targets"
---@param event string
---@param binding string?
function Controller:Listen(controller, event, binding)
  local obj = self

  if binding == nil then
    binding = event
  end
  self._signal:Listen(controller, event, function(...) obj[binding](obj, ...) end)
end

---@protected
---@param fn string
---@param field string
function Controller:Bind(fn, field)
  table.insert(self._bindings, {
    fn = fn,
    field = field
  })
end

---@protected
---@param event string
---@vararg any
function Controller:Emit(event, ...)
  self._signal:Emit(self._name, "On" .. event, ...)
end

---@protected
---@param interval number
---@param event string
function Controller:StartInterval(interval, event)
  local obj = self
  local id = self._intervals[event]

  if id ~= nil then
    self._signal:UnregisterInterval(id)
  end
  self._intervals[event] = self._signal:RegisterInterval(interval, function() obj[event](obj) end)
end

---@protected
---@param event string
function Controller:StopInterval(event)
  local id = self._intervals[event]

  if id == nil then
    return
  end
  self._signal:UnregisterInterval(id)
  self._intervals[event] = nil
end

function Controller:Stop()
  --
end

return Controller
