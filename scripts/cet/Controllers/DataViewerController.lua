local Utils = require_verbose("Utils")
local Controller = require_verbose("Controllers/Controller")

local DataViewerController = Controller:new()

function DataViewerController:new(signal)
  local obj = Controller:new(signal)
  setmetatable(obj, { __index = DataViewerController })

  obj.types = { "Bool", "Int32", "Int64", "Uint32", "Uint64", "Float", "Double", "String", "CName", "Vector2", "Vector3",
    "Vector4" }
  obj.typeIndex = 0
  obj.type = nil
  obj.size = 0

  obj.targetAddress = nil
  obj.frame = nil
  obj.offset = nil
  signal:Listen("targets", "OnTargetSelected", function(target) obj.targetAddress = target:GetAddress() end)
  signal:Listen("memory", "OnFrameChanged", function(frame) obj.frame = frame end)
  signal:Listen("memory", "OnOffsetSelected", function(offset) obj.offset = offset end)
  signal:Listen("properties", "OnPropertyHovered", function(prop) obj:OnPropertySelected(prop) end)
  signal:Listen("properties", "OnPropertySelected", function(prop) obj:OnPropertySelected(prop) end)
  return obj
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
      self.signal:Emit("dataViewer", "OnTypeChanged", self.type, self.size)
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
  self.signal:Emit("dataViewer", "OnTypeChanged", self.type, self.size)
end

return DataViewerController
