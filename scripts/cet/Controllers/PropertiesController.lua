local MemoryProperty = require_verbose("Data/MemoryProperty")

local Controller = require_verbose("Controllers/Controller")

local PropertiesController = Controller:new()

function PropertiesController:new(signal)
  local obj = Controller:new(signal)
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

function PropertiesController:Load(target)
  self:Reset()
  if target == nil then
    return
  end
  self.properties = MemoryProperty.ToTable(target:GetProperties())
end

function PropertiesController:ResetHover()
  if self.isFocused then
    return
  end
  self.hovered.index = nil
  self:Emit("properties", "OnPropertyHovered", nil)
end

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
  self:Emit("properties", "OnPropertyHovered", property)
end

function PropertiesController:SelectProperty(index)
  local property

  if self.selected.index == index or index > #self.properties then
    self.selected.index = nil
    property = nil
  else
    self.selected.index = index
    property = self.properties[index].handle
  end
  self:Emit("properties", "OnPropertySelected", property)
end

return PropertiesController
