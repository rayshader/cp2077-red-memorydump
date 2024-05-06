local AddCustomTarget = require_verbose("AddCustomTarget")

local TargetsController = {}

function TargetsController:new(signal)
  local obj = {}
  setmetatable(obj, { __index = TargetsController })

  obj.signal = signal
  obj.targets = {
    --handle:MemoryTarget
  }
  obj.targetIndex = 0
  obj.target = nil
  return obj
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
  local target = AddCustomTarget()

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
