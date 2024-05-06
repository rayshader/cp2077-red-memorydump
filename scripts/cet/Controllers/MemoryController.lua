local Controller = require_verbose("Controllers/Controller")

local MemoryController = Controller:new()

function MemoryController:new(signal)
  local obj = Controller:new(signal)
  setmetatable(obj, { __index = MemoryController })

  obj.frames = {}
  obj.frameIndex = 0
  obj.frame = nil
  obj.hover = {
    offset = -1,
    size = 1
  }
  obj.selection = {
    offset = -1,
    size = 1
  }
  obj.addressForm = {
    offset = nil,
    name = nil,
    type = nil,
    address = nil,
    size = 0x38,
  }

  obj.properties = {}
  obj.hideProperties = true
  obj.property = {
    hovered = nil,
    selected = nil
  }
  signal:Listen("targets", "OnTargetSelected", function(target) obj:Load(target) end)
  signal:Listen("targets", "OnFrameCaptured", function(frame) obj:AddFrame(frame) end)
  signal:Listen("dataViewer", "OnTypeChanged", function(_, size) obj:SetDataType(size) end)
  signal:Listen("options", "OnPropertiesToggled", function(value) obj.hideProperties = value end)
  signal:Listen("properties", "OnPropertyHovered", function(prop) obj:HoverProperty(prop) end)
  signal:Listen("properties", "OnPropertySelected", function(prop) obj:SelectProperty(prop) end)
  return obj
end

function MemoryController:Reset()
  self.frames = {}
  self.frameIndex = 0
  self.frame = nil
  self.hover.offset = -1
  self.selection.offset = -1
  self:ResetAddressForm()

  self.properties = {}
  self.property.hovered = nil
  self.property.selected = nil
end

function MemoryController:ResetAddressForm()
  self.addressForm = {
    offset = nil,
    name = nil,
    type = nil,
    address = nil,
    size = 0x38,
  }
end

function MemoryController:Load(target)
  self:Reset()
  if target == nil then
    return
  end
  self.properties = target:GetProperties()
  self.frames = target:GetFrames()
  self:SelectFrame(#self.frames)
end

function MemoryController:SetDataType(size)
  self.hover.size = size
  self.selection.size = size
end

function MemoryController:HoverProperty(property)
  if self.property.hovered == property then
    return
  end
  self.property.hovered = property
  self.hover.offset = property:GetOffset()
  self.hover.size = property:GetTypeSize()
  self.signal:Emit("memory", "OnOffsetSelected", self.hover.offset)
end

function MemoryController:SelectProperty(property)
  if self.property.selected == property then
    return
  end
  self.property.selected = property
  self.selection.offset = property:GetOffset()
  self.selection.size = property:GetTypeSize()
  self.signal:Emit("memory", "OnOffsetHovered", self.selection.offset)
end

function MemoryController:AddFrame(frame)
  table.insert(self.frames, frame)
  self:SelectFrame(self.frameIndex + 1)
end

function MemoryController:SelectFrame(index)
  if self.frameIndex == index then
    return
  end
  if index < 1 or index > #self.frames then
    return
  end
  self.frameIndex = index
  self.frame = self.frames[index]
  self.signal:Emit("memory", "OnFrameChanged", self.frame)
end

function MemoryController:PreviousFrame()
  self.frameIndex = self.frameIndex - 1
  if self.frameIndex < 1 then
    self.frameIndex = #self.frames
  end
  self.frame = self.frames[self.frameIndex]
  self.signal:Emit("memory", "OnFrameChanged", self.frame)
end

function MemoryController:NextFrame()
  self.frameIndex = self.frameIndex + 1
  if self.frameIndex > #self.frames then
    self.frameIndex = 1
  end
  self.frame = self.frames[self.frameIndex]
  self.signal:Emit("memory", "OnFrameChanged", self.frame)
end

function MemoryController:Hover(offset)
  if self.hover.offset == offset then
    return
  end
  self.hover.offset = offset
  self.signal:Emit("memory", "OnOffsetHovered", offset)
end

function MemoryController:Select(offset)
  if self.selection.offset == offset then
    self.selection.offset = -1
  else
    self.selection.offset = offset
  end
  self.signal:Emit("memory", "OnOffsetSelected", offset)
end

function MemoryController:SubmitAddressForm()
  local form = self.addressForm

  self.signal:Emit("memory", "OnAddressFormSent", form.name, form.type, form.address, form.size)
  self:ResetAddressForm()
end

return MemoryController
