local MemoryProperty = require_verbose("Data/MemoryProperty")

local Controller = require_verbose("Controllers/Controller")

---@class PropertiesController : Controller
---@field properties MemoryProperty[]
---@field isFocused boolean
---@field hovered {index: number?}
---@field selected {index: number?}
local PropertiesController = Controller:new()

---@param signal Signal
function PropertiesController:new(signal)
  local obj = Controller:new("properties", signal)
  setmetatable(obj, { __index = PropertiesController })

  obj.properties = {}
  obj.isFocused = false
  obj.hovered = {
    index = nil
  }
  obj.selected = {
    index = nil
  }

  obj:Listen("targets", "OnTargetSelected", function(target) obj:Load(target) end)
  return obj
end

function PropertiesController:Reset()
  self.properties = {}
  self.isFocused = false
  self.hovered.index = nil
  self.selected.index = nil
end

---@param target any
function PropertiesController:Load(target)
  self:Reset()
  if target == nil or not IsDefined(target) then
    return
  end
  self.properties = MemoryProperty.ToTable(target:GetProperties())
end

function PropertiesController:ResetHover()
  if self.isFocused then
    return
  end
  self.hovered.index = nil
  self:Emit("OnPropertyHovered", nil)
end

---@param index number
function PropertiesController:HoverProperty(index)
  if self.hovered.index == index then
    return
  end
  self.hovered.index = index
  local property

  if index == nil or index > #self.properties then
    property = nil
  else
    property = self.properties[index].handle
  end
  self:Emit("OnPropertyHovered", property)
end

---@param index number
function PropertiesController:SelectProperty(index)
  local property

  if self.selected.index == index or index > #self.properties then
    self.selected.index = nil
    property = nil
  else
    self.selected.index = index
    property = self.properties[index].handle
  end
  self:Emit("OnPropertySelected", property)
end

return PropertiesController
