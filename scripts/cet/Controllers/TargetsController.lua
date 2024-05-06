local Controller = require_verbose("Controllers/Controller")

local TargetsController = Controller:new()

function TargetsController:new(signal, customTarget)
  local obj = Controller:new(signal)
  setmetatable(obj, { __index = TargetsController })

  obj.customTarget = customTarget
  obj.targets = {
    --handle:MemoryTarget
  }
  obj.targetIndex = 0
  obj.target = nil

  signal:Listen("memory", "OnAddressFormSent", function(...) obj:OnAddressFormSent(...) end)
  return obj
end

function TargetsController:OnAddressFormSent(name, type, address, size)
  local target = MemoryDump.TrackAddress(name, type, address, size)

  self:AddTarget(target)
end

function TargetsController:AddTarget(target)
  if target == nil then
    print("[RedMemoryDump] Ignoring 'nil' target.")
    return
  end
  table.insert(self.targets, target)
  self.signal:Emit("targets", "OnTargetAdded", target)
  if self.targetIndex == 0 then
    self:SelectTarget(1)
  end
end

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
  self.signal:Emit("targets", "OnTargetSelected", self.target)
end

function TargetsController:RemoveTarget()
  if self.targetIndex == 0 then
    return
  end
  local target = self.target

  table.remove(self.targets, self.targetIndex)
  self.signal:Emit("targets", "OnTargetRemoved", target)
  self:SelectTarget(self.targetIndex - 1)
end

function TargetsController:AddCustomTarget()
  if self.customTarget == nil then
    print("[RedMemoryDump] Make sure \"RedMemoryDump/AddCustomTarget.lua\" is defined.")
    return
  end
  local target = self.customTarget.api.AddCustomTarget(self.customTarget.context)

  if target == nil then
    print("[RedMemoryDump] Failed to track target, ignoring...")
    return
  end
  self:AddTarget(target)
end

function TargetsController:Capture()
  if self.target == nil then
    return
  end
  local frame = self.target:Capture()

  self.signal:Emit("targets", "OnFrameCaptured", frame)
end

return TargetsController
