local Controller = require_verbose("Controllers/Controller")

---@class TargetsController : Controller
---@field rht RedHotTools
---@field customTarget any
---
---@field targets MemoryTarget[]
---@field targetIndex number
---@field target MemoryTarget?
---
---@field isRecording boolean
---@field recordRate number
---
---@field worldObjects WorldObjectItem[]
---@field worldObjectIndex number
local TargetsController = Controller:new()

---@param signal Signal
---@param customTarget any
---@overload fun(signal: Signal): TargetsController
function TargetsController:new(signal, customTarget)
  ---@type TargetsController
  local obj = Controller:new("targets", signal)
  setmetatable(obj, { __index = TargetsController })

  obj.rht = nil

  obj.customTarget = customTarget
  obj.customTarget.context.Capture = function() obj:Capture() end

  obj.targets = {}
  obj.targetIndex = 0
  obj.target = nil

  obj.isRecording = false
  obj.recordRate = 66

  obj.worldObjects = {}
  obj.worldObjectIndex = 1

  obj:Listen("hotkey", "OnRecordToggled")
  obj:Listen("memory", "OnAddressFormSent")
  return obj
end

function TargetsController:Load()
  self.rht = GetMod("RedHotTools")
end

---@return boolean
function TargetsController:HasRHT()
  return self.rht ~= nil
end

---@private
function TargetsController:OnRecordToggled()
  if not self.isRecording then
    self:StartRecording()
  else
    self:StopRecording()
  end
end

---@private
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
  self:Emit("TargetAdded", target)
  if self.targetIndex == 0 then
    self:SelectTarget(1)
  end
end

---@param index number
function TargetsController:SelectTarget(index)
  if self.targetIndex == index then
    return
  end
  if self.isRecording then
    self:StopRecording()
  end
  if index < 1 or index > #self.targets then
    self.targetIndex = 0
    self.target = nil
  else
    self.targetIndex = index
    self.target = self.targets[index]
  end
  self:Emit("TargetSelected", self.target)
end

function TargetsController:RemoveTarget()
  if self.targetIndex == 0 then
    return
  end
  local target = self.target

  table.remove(self.targets, self.targetIndex)
  self:Emit("TargetRemoved", target)
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

---@param index number
function TargetsController:SelectWorldTarget(index)
  if not self:HasRHT() then
    return
  end
  if self.worldObjectIndex == index then
    return
  end
  if index < 2 or index > #self.worldObjects then
    self.worldObjectIndex = 1
    return
  end
  local object = self.worldObjects[index]

  if object == nil or object.item == nil then
    return
  end
  self.worldObjectIndex = index
end

function TargetsController:AddWorldTarget()
  if not self:HasRHT() then
    return
  end
  if self.worldObjectIndex == 0 then
    return
  end
  local object = self.worldObjects[self.worldObjectIndex]
  local handle = nil

  if object.item.isEntity then
    handle = object.item.entity
  else
    handle = object.item.nodeInstance
  end
  if handle == nil or not IsDefined(handle) then
    print("[RedMemoryDump] World object is undefined.")
    return
  end
  local target = MemoryDump.TrackSerializable(handle)

  self:AddTarget(target)
end

---@return WorldObjectItem[]
function TargetsController:GetWorldObjects()
  if not self:HasRHT() then
    return {}
  end
  self.worldObjects = {{label = "<None>", item = nil}}
  --[[
  local result = self.rht.GetWorldInspectorTarget()

  if result ~= nil then
    table.insert(self.worldObjects, {label = "-- Target --", item = nil})
    table.insert(self.worldObjects, {label = nil, item = result})
    return self.worldObjects
  end
  --]]
  --[[
  results = self.rht.GetLookAtObjects() or {}
  if #results > 0 then
    table.insert(self.worldObjects, {label = "-- LookAt --", item = nil})
  end
  for _, result in ipairs(results) do
    table.insert(self.worldObjects, {label = nil, item = result})
  end
  --]]
  local results = self.rht.GetWorldScannerFilteredResults() or {}

  if #results == 0 then
    results = self.rht.GetWorldScannerResults() or {}
  end
  if #results > 0 then
    table.insert(self.worldObjects, {label = "-- Scanner --", item = nil})
  end
  for _, result in ipairs(results) do
    table.insert(self.worldObjects, {label = nil, item = result})
  end
  return self.worldObjects
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

---@return boolean
function TargetsController:Capture()
  if self:IsTargetDisposed() then
    print("[RedMemoryDump] Target is undefined.")
    return false
  end
  local frame = self.target:Capture()

  if frame == nil or not IsDefined(frame) then
    print("[RedMemoryDump] Failed to dump target.")
    return false
  end
  self:Emit("FrameCaptured", frame)
  return true
end

function TargetsController:StartRecording()
  if self.isRecording then
    return
  end
  if not self:IsTargetSelected() or self:IsTargetDisposed() then
    return
  end
  local rate = self.recordRate / 1000.0

  self:StartInterval(rate, "OnRecordTick")
  self.isRecording = true
end

function TargetsController:OnRecordTick()
  if not self.isRecording then
    return
  end
  local isCaptured = self:Capture()

  if isCaptured then
    return
  end
  self:StopRecording()
end

function TargetsController:StopRecording()
  if not self.isRecording then
    return
  end
  self:StopInterval("OnRecordTick")
  self.isRecording = false
end

return TargetsController
