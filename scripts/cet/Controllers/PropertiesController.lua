local MemoryProperty = require_verbose("Data/MemoryProperty")

local Controller = require_verbose("Controllers/Controller")

local PropertiesController = Controller:new()

function PropertiesController:new(signal)
  local obj = Controller:new(signal)
  setmetatable(obj, { __index = PropertiesController })

  obj.properties = {}
  obj.hovered = {
    index = nil,
    property = nil
  }
  obj.selected = {
    index = nil,
    property = nil
  }

  obj:Listen("targets", "OnTargetSelected", function(target) obj:Load(target) end)
  return obj
end

function PropertiesController:Reset()
  self.properties = {}
  self.hovered.index = nil
  self.hovered.property = nil
  self.selected.index = nil
  self.selected.property = nil
end

function PropertiesController:Load(target)
  self:Reset()
  if target == nil then
    return
  end
  self.properties = MemoryProperty.ToTable(target:GetProperties())
end

function PropertiesController:HoverProperty(index)
  if self.hovered.index == index then
    return
  end
  self.hovered.index = index
  if index == nil or index > #self.properties then
    self.hovered.property = nil
  else
    self.hovered.property = self.properties[index].handle
  end
  self:Emit("properties", "OnPropertyHovered", self.hovered.property)
end

function PropertiesController:SelectProperty(index)
  if self.selected.index == index or index > #self.properties then
    self.selected.index = nil
    self.selected.property = nil
  else
    self.selected.index = index
    self.selected.property = self.properties[index].handle
  end
  self:Emit("properties", "OnPropertySelected", self.selected.property)
end

return PropertiesController
