local MemoryProperty = require_verbose("Data/MemoryProperty")

local Controller = require_verbose("Controllers/Controller")

---@class MemoryController : Controller
---@field frames any[]
---@field frameIndex number
---@field frame any | nil
---@field bytes string[] | nil
---@field isHovered boolean
---@field hover {offset: number, size: number}
---@field selection {offset: number, size: number}
---@field addressForm {offset: number | nil, name: string | nil, type: string | nil, address: number | nil, size: number}
---@field start number
---@field elapsedTime number
---@field properties MemoryProperty[]
---@field hideProperties boolean
---@field property {hovered: any | nil, selected: any | nil, needScroll: boolean}
local MemoryController = Controller:new()

---@param signal Signal
function MemoryController:new(signal)
  local obj = Controller:new(signal)
  setmetatable(obj, { __index = MemoryController })

  obj.frames = {}
  obj.frameIndex = 0
  obj.frame = nil
  obj.bytes = nil
  obj.isHovered = false
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

  obj.start = os.clock()
  obj.elapsedTime = os.clock() - obj.start

  obj.properties = {}
  obj.hideProperties = true
  obj.property = {
    hovered = nil,
    selected = nil,
    needScroll = false
  }
  obj:Listen("targets", "OnTargetSelected", function(target) obj:Load(target) end)
  obj:Listen("targets", "OnFrameCaptured", function(frame) obj:AddFrame(frame) end)
  obj:Listen("dataViewer", "OnTypeChanged", function(_, size) obj:SetDataType(size) end)
  obj:Listen("options", "OnPropertiesToggled", function(value) obj.hideProperties = value end)
  obj:Listen("properties", "OnPropertyHovered", function(prop) obj:HoverProperty(prop) end)
  obj:Listen("properties", "OnPropertySelected", function(prop) obj:SelectProperty(prop) end)
  return obj
end

function MemoryController:Reset()
  self.frames = {}
  self.frameIndex = 0
  self.frame = nil
  self.bytes = nil
  self.isHovered = false
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
  if target == nil or not IsDefined(target) then
    return
  end
  self.properties = MemoryProperty.ToTable(target:GetProperties())
  self.frames = target:GetFrames()
  self:SelectFrame(#self.frames)
end

---@param size number
function MemoryController:SetDataType(size)
  self.hover.size = size
  self.selection.size = size
end

---@param property any
function MemoryController:HoverProperty(property)
  if self.property.hovered == property then
    return
  end
  self.property.hovered = property
  self.property.needScroll = false
  if property ~= nil then
    self.property.needScroll = true and self.property.selected == nil
    self.hover.offset = property:GetOffset()
    self.hover.size = property:GetTypeSize()
  end
  self:Emit("memory", "OnOffsetHovered", self.hover.offset)
end

---@param property any
function MemoryController:SelectProperty(property)
  if self.property.selected == property then
    return
  end
  self.property.selected = property
  if property ~= nil then
    self.selection.offset = property:GetOffset()
    self.selection.size = property:GetTypeSize()
  end
  self:Emit("memory", "OnOffsetSelected", self.selection.offset)
end

---@param frame any
function MemoryController:AddFrame(frame)
  table.insert(self.frames, frame)
  self:SelectFrame(self.frameIndex + 1)
end

---@param index number
function MemoryController:SelectFrame(index)
  if self.frameIndex == index then
    return
  end
  if index < 1 or index > #self.frames then
    return
  end
  self.frameIndex = index
  self.frame = self.frames[index]
  if self.frame ~= nil then
    self.bytes = self.frame:GetBufferView()
  end
  self:Emit("memory", "OnFrameChanged", self.frame)
end

function MemoryController:PreviousFrame()
  self.frameIndex = self.frameIndex - 1
  if self.frameIndex < 1 then
    self.frameIndex = #self.frames
  end
  self.frame = self.frames[self.frameIndex]
  if self.frame ~= nil then
    self.bytes = self.frame:GetBufferView()
  end
  self:Emit("memory", "OnFrameChanged", self.frame)
end

function MemoryController:NextFrame()
  self.frameIndex = self.frameIndex + 1
  if self.frameIndex > #self.frames then
    self.frameIndex = 1
  end
  self.frame = self.frames[self.frameIndex]
  if self.frame ~= nil then
    self.bytes = self.frame:GetBufferView()
  end
  self:Emit("memory", "OnFrameChanged", self.frame)
end

function MemoryController:ResetHover()
  if self.isHovered or self.property.hovered ~= nil then
    return
  end
  self.hover.offset = -1
end

---@param offset number
function MemoryController:Hover(offset)
  if self.hover.offset == offset then
    return
  end
  self.hover.offset = offset
end

---@param offset number
function MemoryController:Select(offset)
  if self.selection.offset == offset then
    self.selection.offset = -1
  else
    self.selection.offset = offset
  end
  self:Emit("memory", "OnOffsetSelected", self.selection.offset)
end

function MemoryController:SubmitAddressForm()
  local form = self.addressForm

  self:Emit("memory", "OnAddressFormSent", form.name, form.type, form.address, form.size)
  self:ResetAddressForm()
end

return MemoryController
