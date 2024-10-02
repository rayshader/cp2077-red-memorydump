local MemoryProperty = require_verbose("Data/MemoryProperty")

local Controller = require_verbose("Controllers/Controller")

---@class PropertiesViewModel
---@field properties MemoryProperty[]
---@field selected number?

---@class PropertiesController : Controller, PropertiesViewModel
local PropertiesController = Controller:new()

---@param signal Signal
function PropertiesController:new(signal)
  ---@type PropertiesController
  local obj = Controller:new("properties", signal)
  setmetatable(obj, { __index = PropertiesController })

  obj.properties = {}
  obj.selected = -1

  obj:Listen("targets", "OnTargetSelected")
  return obj
end

function PropertiesController:Load()
  Controller.Load(self)

  self.selected = nil
end

function PropertiesController:Reset()
  self.properties = {}
  self.selected = nil
end

---@private
---@param target MemoryTarget?
function PropertiesController:OnTargetSelected(target)
  self:Reset()
  if target == nil or not IsDefined(target) then
    return
  end
  self.properties = MemoryProperty.ToTable(target:GetProperties())
end

---@param index number
function PropertiesController:SelectProperty(index)
  local property

  if self.selected == index or index > #self.properties then
    self.selected = nil
    property = nil
  else
    self.selected = index
    property = self.properties[index].handle
  end
  self:Emit("PropertySelected", property)
end

return PropertiesController
