local Controller = require_verbose("Controllers/Controller")

---@class ToolsController : Controller
---@field types string[]
---@field typeIndex number
---@field type string | nil
local ToolsController = Controller:new()

---@param signal Signal
function ToolsController:new(signal)
  local obj = Controller:new(signal)
  setmetatable(obj, { __index = ToolsController })

  obj.types = { "Int32", "Int64", "Uint32", "Uint64", "Float", "Double", "String", "CName" }
  obj.typeIndex = 0
  obj.type = nil
  return obj
end

---@param index number
function ToolsController:SelectType(index)
  if self.typeIndex == index then
    return
  end
  self.typeIndex = index
  self.type = self.types[index]
  self:Emit("tools", "OnTypeChanged", self.type)
end

return ToolsController
