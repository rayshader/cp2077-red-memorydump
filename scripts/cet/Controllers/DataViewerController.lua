local Utils = require_verbose("Utils")
local Controller = require_verbose("Controllers/Controller")

---@class DataViewerController : Controller
---@field types string[]
---@field typeIndex number
---@field type string?
---@field size number
---@field targetAddress number?
---@field frame any?
---@field offset number?
---@field warning boolean
local DataViewerController = Controller:new()

---@param signal Signal
function DataViewerController:new(signal)
  ---@type DataViewerController
  local obj = Controller:new("dataViewer", signal)
  setmetatable(obj, { __index = DataViewerController })

  obj.types = Utils.typeLabels
  obj.typeIndex = 0
  obj.type = "Bool"
  obj.size = 1

  obj.targetAddress = nil
  obj.frame = nil
  obj.offset = nil
  obj.warning = true
  obj:Listen("targets", "OnTargetSelected")
  obj:Listen("memory", "OnFrameChanged")
  obj:Listen("memory", "OnOffsetSelected")
  obj:Listen("properties", "OnPropertyHovered", "OnPropertySelected")
  obj:Listen("properties", "OnPropertySelected")
  return obj
end

---@private
---@param target MemoryTarget?
function DataViewerController:OnTargetSelected(target)
  if target == nil or not IsDefined(target) then
    return
  end
  self.typeIndex = 0
  self.type = "Bool"
  self.size = 1

  self.targetAddress = target:GetAddress()
  self.offset = nil
  self.warning = true
  self:Emit("TypeChanged", self.type, self.size)
end

---@private
---@param frame MemoryFrame?
function DataViewerController:OnFrameChanged(frame)
  self.frame = frame
end

---@private
---@param offset number?
function DataViewerController:OnOffsetSelected(offset)
  if offset == -1 then
    offset = nil
  end
  self.offset = offset
end

---@private
---@param property any
function DataViewerController:OnPropertySelected(property)
  if property == nil or not IsDefined(property) then
    return
  end
  local type = NameToString(property:GetTypeName())
  local size = property:GetTypeSize()

  for i, typeName in ipairs(self.types) do
    if type == typeName then
      self.typeIndex = i - 1
      self.type = type
      self.size = size
      self.warning = true
      self:Emit("TypeChanged", self.type, self.size)
      return
    end
  end
end

---@param index number
function DataViewerController:SelectType(index)
  if self.typeIndex == index then
    return
  end
  self.typeIndex = index
  self.type = self.types[index + 1]
  self.size = Utils.GetTypeSize(self.type)
  self.warning = true
  self:Emit("TypeChanged", self.type, self.size)
end

return DataViewerController
