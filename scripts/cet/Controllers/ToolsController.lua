local Controller = require_verbose("Controllers/Controller")

local ToolsController = Controller:new()

function ToolsController:new(signal)
  local obj = Controller:new(signal)
  setmetatable(obj, { __index = ToolsController })

  obj.types = { "Int32", "Int64", "Uint32", "Uint64", "Float", "Double", "String", "CName" }
  obj.typeIndex = 0
  obj.type = nil
  return obj
end

function ToolsController:SelectType(index)
  if self.typeIndex == index then
    return
  end
  self.typeIndex = index
  self.type = self.types[index]
  self.signal:Emit("tools", "OnTypeChanged", self.type)
end

return ToolsController
