local Utils = require_verbose("Utils")
local Controller = require_verbose("Controllers/Controller")

local DataViewerController = Controller:new()

function DataViewerController:new(signal)
  local obj = Controller:new(signal)
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

function DataViewerController:Load(target)
  if target == nil then
    return
  end
  self.typeIndex = 0
  self.type = "Bool"
  self.size = 1

  self.targetAddress = target:GetAddress()
  self.offset = nil
  self:Emit("dataViewer", "OnTypeChanged", self.type, self.size)
end

function DataViewerController:OnOffsetSelected(offset)
  if offset == -1 then
    offset = nil
  end
  self.offset = offset
end

function DataViewerController:OnPropertySelected(property)
  if property == nil then
    return
  end
  local type = NameToString(property:GetTypeName())
  local size = property:GetTypeSize()

  for i, typeName in ipairs(self.types) do
    if type == typeName then
      self.typeIndex = i - 1
      self.type = type
      self.size = size
      self:Emit("dataViewer", "OnTypeChanged", self.type, self.size)
      return
    end
  end
end

function DataViewerController:SelectType(index)
  if self.typeIndex == index then
    return
  end
  self.typeIndex = index
  self.type = self.types[index + 1]
  self.size = Utils.GetTypeSize(self.type)
  self:Emit("dataViewer", "OnTypeChanged", self.type, self.size)
end

return DataViewerController
