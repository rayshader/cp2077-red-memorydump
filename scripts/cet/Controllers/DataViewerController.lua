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
local DataViewerController = Controller:new()

---@param signal Signal
function DataViewerController:new(signal)
  local obj = Controller:new("dataViewer", signal)
  setmetatable(obj, { __index = DataViewerController })

  obj.types = { "Bool", "Int32", "Int64", "Uint32", "Uint64", "Float", "Double", "String", "CName", "Vector2", "Vector3",
    "Vector4", "Quaternion", "EulerAngles", "WorldPosition", "WorldTransform" }
  obj.typeIndex = 0
  obj.type = "Bool"
  obj.size = 1

  obj.targetAddress = nil
  obj.frame = nil
  obj.offset = nil
  obj:Listen("targets", "OnTargetSelected", function(target) obj:Load(target) end)
  obj:Listen("memory", "OnFrameChanged", function(frame) obj.frame = frame end)
  obj:Listen("memory", "OnOffsetSelected", function(offset) obj:OnOffsetSelected(offset) end)
  obj:Listen("properties", "OnPropertyHovered", function(prop) obj:OnPropertySelected(prop) end)
  obj:Listen("properties", "OnPropertySelected", function(prop) obj:OnPropertySelected(prop) end)
  return obj
end

---@param target any
function DataViewerController:Load(target)
  if target == nil or not IsDefined(target) then
    return
  end
  self.typeIndex = 0
  self.type = "Bool"
  self.size = 1

  self.targetAddress = target:GetAddress()
  self.offset = nil
  self:Emit("OnTypeChanged", self.type, self.size)
end

---@param offset number?
function DataViewerController:OnOffsetSelected(offset)
  if offset == -1 then
    offset = nil
  end
  self.offset = offset
end

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
      self:Emit("OnTypeChanged", self.type, self.size)
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
  self:Emit("OnTypeChanged", self.type, self.size)
end

return DataViewerController
