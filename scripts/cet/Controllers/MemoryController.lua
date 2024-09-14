local Utils = require_verbose("Utils")

local MemoryProperty = require_verbose("Data/MemoryProperty")

local Controller = require_verbose("Controllers/Controller")

---@class MemoryController : Controller
---@field frames MemoryFrame[]
---@field frameIndex number
---@field frame MemoryFrame?
---@field view string[]?
---@field views string[][]
---@field isHovered boolean
---@field hover {offset: number, size: number}
---@field selection {offset: number, size: number}
---@field addressForm {offset: number?, name: string?, type: string?, address: number?, size: number}
---@field frameRate number
---@field start number
---@field elapsedTime number
---@field properties MemoryProperty[]
---@field hideProperties boolean
---@field property {hovered: any?, selected: any?, needScroll: boolean}
local MemoryController = Controller:new()

---@param signal Signal
function MemoryController:new(signal)
  local obj = Controller:new("memory", signal)
  setmetatable(obj, { __index = MemoryController })

  obj.target = nil
  obj.frames = {}
  obj.frameIndex = 0
  obj.frame = nil
  obj.view = nil
  obj.views = {}
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

  obj.frameRate = 1.0 / 60.0
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
  obj:Listen("options", "OnPropertiesToggled", function(isHidden) obj:ChangePropertiesVisibility(isHidden) end)
  obj:Listen("properties", "OnPropertyHovered", function(prop) obj:HoverProperty(prop) end)
  obj:Listen("properties", "OnPropertySelected", function(prop) obj:SelectProperty(prop) end)
  return obj
end

function MemoryController:Reset()
  self.target = nil
  self.frames = {}
  self.frameIndex = 0
  self.frame = nil
  self.view = nil
  self.views = {}
  self.isHovered = false
  self.hover.offset = -1
  self.selection.offset = -1
  self:ResetAddressForm()

  self.properties = {}
  self.property.hovered = nil
  self.property.selected = nil
  self.property.needScroll = false
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
  self.target = target
  self.properties = MemoryProperty.ToTable(target:GetProperties())
  self.frames = target:GetFrames()
  for _, frame in ipairs(self.frames) do
    local bytes = frame:GetBufferView()
    local view = self:BuildView(bytes)

    table.insert(self.views, view)
  end
  self:SelectFrame(#self.frames)
end

---@param bytes string[]
---@return [string, MemoryProperty][]
function MemoryController:BuildView(bytes)
  if not self.hideProperties then
    return bytes
  end
  local view = {}
  local property = nil

  for i, byte in ipairs(bytes) do
    byte, property = self:ObfuscateByte(i - 1, byte, property)
    table.insert(view, byte)
  end
  return view
end

---@param offset number
---@param byte string
---@param property MemoryProperty?
---@return string, MemoryProperty
function MemoryController:ObfuscateByte(offset, byte, property)
  if property ~= nil and not Utils.IsInRange(offset, property.offset, property.size) then
    property = nil
  end
  if property == nil then
    property = Utils.FindProperty(self.properties, offset)
  end
  if property ~= nil and not Utils.IsTypeUnknown(property.type) then
    byte = "__"
  end
  return byte, property
end

---@param size number
function MemoryController:SetDataType(size)
  self.hover.size = size
  self.selection.size = size
end

---@param isHidden boolean
function MemoryController:ChangePropertiesVisibility(isHidden)
  if self.hideProperties == isHidden then
    return
  end
  self.hideProperties = isHidden
  for i, frame in ipairs(self.frames) do
    local bytes = frame:GetBufferView()

    self.views[i] = self:BuildView(bytes)
  end
  self.view = self.views[self.frameIndex]
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
  self:Emit("OnOffsetHovered", self.hover.offset)
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
  self:Emit("OnOffsetSelected", self.selection.offset)
end

function MemoryController:HasFrames()
  return #self.frames > 0
end

---@param frame any
function MemoryController:AddFrame(frame)
  local bytes = frame:GetBufferView()
  local view = self:BuildView(bytes)

  table.insert(self.frames, frame)
  table.insert(self.views, view)
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
  self:UpdateFrame()
end

function MemoryController:PreviousFrame()
  if not self:HasFrames() then
    return
  end
  self.frameIndex = self.frameIndex - 1
  if self.frameIndex < 1 then
    self.frameIndex = #self.frames
  end
  self:UpdateFrame()
end

function MemoryController:NextFrame()
  if not self:HasFrames() then
    return
  end
  self.frameIndex = self.frameIndex + 1
  if self.frameIndex > #self.frames then
    self.frameIndex = 1
  end
  self:UpdateFrame()
end

function MemoryController:DeleteFrame()
  if #self.frames == 0 then
    return
  end
  self.target:RemoveFrame(self.frameIndex - 1)
  table.remove(self.frames, self.frameIndex)
  table.remove(self.views, self.frameIndex)
  local index = self.frameIndex - 1

  if index < 1 then
    index = 1
  end
  self:SelectFrame(index)
  if self:HasFrames() then
    return
  end
  self.frames = {}
  self.frameIndex = 0
  self.view = nil
  self.views = {}
  self:Emit("OnFrameChanged", self.frame)
end

--- @private
function MemoryController:UpdateFrame()
  self.frame = self.frames[self.frameIndex]
  self.view = self.views[self.frameIndex]
  self:Emit("OnFrameChanged", self.frame)
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
  self:Emit("OnOffsetSelected", self.selection.offset)
end

function MemoryController:SubmitAddressForm()
  local form = self.addressForm

  self:Emit("OnAddressFormSent", form.name, form.type, form.address, form.size)
  self:ResetAddressForm()
end

return MemoryController
