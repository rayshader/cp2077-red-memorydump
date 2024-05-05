local Utils = require_verbose("Utils")

local DataViewerController = {}

function DataViewerController:new(signal)
  local obj = {}
  setmetatable(obj, { __index = DataViewerController })

  obj.signal = signal
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
  return obj
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
