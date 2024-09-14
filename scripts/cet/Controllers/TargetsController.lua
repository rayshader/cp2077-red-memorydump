local Controller = require_verbose("Controllers/Controller")

---@class TargetsController : Controller
---@field customTarget any
---@field targets any[]
---@field targetIndex number
---@field target any?
local TargetsController = Controller:new()

---@param signal Signal
---@param customTarget any
---@overload fun(signal: Signal): TargetsController
function TargetsController:new(signal, customTarget)
  local obj = Controller:new("targets", signal)
  setmetatable(obj, { __index = TargetsController })

  obj.customTarget = customTarget
  obj.customTarget.context.Capture = function() obj:Capture() end
  obj.targets = {
    --handle:MemoryTarget
  }
  obj.targetIndex = 0
  obj.target = nil

  obj:Listen("memory", "OnAddressFormSent", function(...) obj:OnAddressFormSent(...) end)
  return obj
end

---@param name string
---@param type string
---@param address number
---@param size number
function TargetsController:OnAddressFormSent(name, type, address, size)
  local target = MemoryDump.TrackAddress(name, type, address, size)

  self:AddTarget(target)
end

---@param target any
function TargetsController:AddTarget(target)
  if target == nil or not IsDefined(target) then
    print("[RedMemoryDump] Ignoring 'nil' target.")
    return
  end
  table.insert(self.targets, target)
  self:Emit("OnTargetAdded", target)
  if self.targetIndex == 0 then
    self:SelectTarget(1)
  end
end

---@param index number
function TargetsController:SelectTarget(index)
  if self.targetIndex == index then
    return
  end
  if index < 1 or index > #self.targets then
    self.targetIndex = 0
    self.target = nil
  else
    self.targetIndex = index
    self.target = self.targets[index]
  end
  self:Emit("OnTargetSelected", self.target)
end

function TargetsController:RemoveTarget()
  if self.targetIndex == 0 then
    return
  end
  local target = self.target

  table.remove(self.targets, self.targetIndex)
  self:Emit("OnTargetRemoved", target)
  self:SelectTarget(self.targetIndex - 1)
end

function TargetsController:AddCustomTarget()
  if self.customTarget == nil then
    print("[RedMemoryDump] Make sure \"RedMemoryDump/AddCustomTarget.lua\" is defined.")
    return
  end
  ---@type "AddTarget" | "AddCustomTarget"
  local fnName = "AddTarget"

  if self.customTarget.api.AddCustomTarget ~= nil then
    fnName = "AddCustomTarget"
    print("[RedMemoryDump] 'AddCustomTarget' is deprecated in favor of 'AddTarget'.")
  end
  local target = self.customTarget.api[fnName](self.customTarget.context)

  if target == nil or not IsDefined(target) then
    print("[RedMemoryDump] Failed to track target, ignoring...")
    return
  end
  self:AddTarget(target)
end

function TargetsController:Capture()
  if self.target == nil or not IsDefined(self.target) then
    return
  end
  local frame = self.target:Capture()

  self:Emit("OnFrameCaptured", frame)
end

return TargetsController
