---@class Signal
---@field private controllers table<string, Controller>
---@field private listeners table<string, table<string, function[]>>
---@field private calls function[]
---@field private timers table<number, {interval: number, triggerIn: number, fn: function}>
---@field private timerKeygen number
---@field private refreshRate number
---@field private refreshTimer number
local Signal = {}

function Signal:new()
  local obj = {}
  setmetatable(obj, { __index = Signal })

  obj.listeners = {
    --[controller] = {
    --  [event] = {fn, ...}
    --}
  }
  obj.calls = {}
  obj.timers = {}
  obj.timerKeygen = 0
  obj.refreshRate = 1 / 30
  obj.refreshTimer = obj.refreshRate
  return obj
end

---@param controllers table<string, Controller>
function Signal:Start(controllers)
  self.controllers = controllers
end

function Signal:Stop()
  self.listeners = nil
  self.calls = nil
  self.timers = nil
  self.timerKeygen = 0
end

---@param controller Controller
---@param fn string
---@vararg any
function Signal:Queue(controller, fn, ...)
  if controller == nil then
    return
  end
  if controller[fn] == nil then
    return
  end
  local args = {...}
  local call

  if args == nil then
    call = function() controller[fn](controller) end
  else
    call = function() controller[fn](controller, table.unpack(args)) end
  end
  table.insert(self.calls, call)
end

---@param controller string
---@param event string
---@param fn function
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

---@param controller string
---@param event string
---@vararg any
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

---@param interval number
---@param fn function
---@return number
function Signal:RegisterInterval(interval, fn)
  local id = self.timerKeygen

  self.timerKeygen = self.timerKeygen + 1
  self.timers[id] = {
    interval = interval,
    triggerIn = interval,
    fn = fn
  }
  return id
end

---@param id number
function Signal:UnregisterInterval(id)
  self.timers[id] = nil
end

---@param delta number
function Signal:Update(delta)
  self:RunCalls(delta)
  self:RunTimers(delta)
end

---@private
---@param delta number
function Signal:RunCalls(delta)
  for _, call in ipairs(self.calls) do
    call()
  end
  self.calls = {}
  self.refreshTimer = self.refreshTimer - delta
  if self.refreshTimer > 0 then
    return
  end
  self.refreshTimer = self.refreshRate
  for _, controller in pairs(self.controllers) do
    controller:Update()
  end
end

---@private
---@param delta number
function Signal:RunTimers(delta)
  local timers = {}

  for _, timer in pairs(self.timers) do
    timer.triggerIn = timer.triggerIn - delta
    if timer.triggerIn <= 0.0 then
      timer.triggerIn = timer.interval
      table.insert(timers, timer)
    end
  end
  for _, timer in ipairs(timers) do
    timer.fn()
  end
end

return Signal
