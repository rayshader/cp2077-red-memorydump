local Controller = require_verbose("Controllers/Controller")

---@class TargetsController : Controller
---@field rht RedHotTools
---@field customTarget any
---
---@field targets MemoryTarget[]
---@field targetIndex number
---@field target MemoryTarget?
local TargetsController = Controller:new()

---@param signal Signal
---@param customTarget any
---@overload fun(signal: Signal): TargetsController
function TargetsController:new(signal, customTarget)
  local obj = Controller:new("targets", signal)
  setmetatable(obj, { __index = TargetsController })

  obj.rht = nil

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

function TargetsController:Load()
  self.rht = GetMod("RedHotTools")
end

function TargetsController:HasRHT()
  return self.rht ~= nil
end

---@param name string
---@param type string
---@param address number
---@param size number
function TargetsController:OnAddressFormSent(name, type, address, size)
  local target = MemoryDump.TrackAddress(name, type, address, size)

  self:AddTarget(target)
end

---@param target MemoryTarget?
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

  self:AddTarget(target)
end

---@param widget inkWidget?
function TargetsController:AddInkTarget(widget)
  if not self:HasRHT() then
    return
  end
  if widget == nil or not IsDefined(widget) then
    print("[RedMemoryDump] Widget is undefined.")
    return
  end
  local target = MemoryDump.TrackSerializable(widget)

  self:AddTarget(target)
end

---@return inkWidget?
function TargetsController:GetInkWidget()
  if not self:HasRHT() then
    return nil
  end
  return self.rht.GetSelectedWidget()
end

---@return boolean
function TargetsController:IsTargetSelected()
  return self.target ~= nil
end

---@return boolean
function TargetsController:IsTargetDisposed()
  return not IsDefined(self.target) or
         self.target:GetSize() == 0 or
         self.target:GetAddress() == 0
end

function TargetsController:Capture()
  if self:IsTargetDisposed() then
    print("[RedMemoryDump] Target is undefined.")
    return
  end
  local frame = self.target:Capture()

  if frame == nil or not IsDefined(frame) then
    print("[RedMemoryDump] Failed to dump target.")
    return
  end
  self:Emit("OnFrameCaptured", frame)
end

return TargetsController
