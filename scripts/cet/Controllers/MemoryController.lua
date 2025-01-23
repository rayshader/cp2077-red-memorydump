local Utils = require_verbose("Utils")

local MemoryProperty = require_verbose("Data/MemoryProperty")

local Controller = require_verbose("Controllers/Controller")

---@alias BufferView string[]
---@alias HeatMapView number[]

---@class MemoryViewModel
---@field frames MemoryFrame[]
---@field frameIndex number
---@field frame MemoryFrame?
---@field view BufferView?
---@field views BufferView[]
---@field selection {offset: number, size: number}
---@field addressForm {offset: number?, name: string?, type: string?, address: number?, size: number}
---
---@field isPlaying boolean
---
---@field properties MemoryProperty[]
---@field hideProperties boolean
---@field property {hovered: any?, selected: any?, needScroll: boolean}
---
---@field showHeatMap boolean
---@field heatMap HeatMapView[]
---@field heatMax number

---@class MemoryController : Controller, MemoryViewModel
local MemoryController = Controller:new()

---@param signal Signal
function MemoryController:new(signal)
  ---@type MemoryController
  local obj = Controller:new("memory", signal)
  setmetatable(obj, { __index = MemoryController })

  obj.target = {}
  obj.frames = {}
  obj.frameIndex = 0
  obj.frame = {}
  obj.view = {}
  obj.views = {}
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

  obj.isPlaying = false

  obj.properties = {}
  obj.hideProperties = true
  obj.property = {
    hovered = nil,
    selected = nil,
    needScroll = false
  }

  obj.showHeatMap = false
  obj.heatMap = {}
  obj.heatMax = 0

  obj:Bind("HasFrames", "hasFrames")

  obj:Listen("targets", "OnTargetSelected")
  obj:Listen("targets", "OnFrameCaptured")
  obj:Listen("dataViewer", "OnTypeChanged")
  obj:Listen("options", "OnHidePropertiesToggled")
  obj:Listen("options", "OnHeatMapToggled")
  obj:Listen("properties", "OnPropertySelected")
  return obj
end

function MemoryController:Load()
  Controller.Load(self)

  self.target = nil
  self.frame = nil
  self.view = nil
end

---@private
---@param target MemoryTarget?
function MemoryController:OnTargetSelected(target)
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
  if self.showHeatMap then
      self.heatMap, self.heatMax = self:BuildHeatMap()
  end
  self:SelectFrame(#self.frames)
end

---@private
---@param frame MemoryFrame
function MemoryController:OnFrameCaptured(frame)
  local bytes = frame:GetBufferView()
  local view = self:BuildView(bytes)

  table.insert(self.frames, frame)
  table.insert(self.views, view)
  if self.showHeatMap then
      self.heatMap, self.heatMax = self:BuildHeatMap()
  end
  self:SelectFrame(self.frameIndex + 1)
end

---@private
---@param type string
---@param size number
function MemoryController:OnTypeChanged(type, size)
  self.selection.size = size
end

---@private
---@param isHidden boolean
function MemoryController:OnHidePropertiesToggled(isHidden)
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

---@private
---@param isVisible boolean
function MemoryController:OnHeatMapToggled(isVisible)
  if self.showHeatMap == isVisible then
    return
  end
  self.showHeatMap = isVisible
  if not self.showHeatMap then
    return
  end
  self.heatMap, self.heatMax = self:BuildHeatMap()
end

---@private
---@param property any
function MemoryController:OnPropertySelected(property)
  if self.property.selected == property then
    return
  end
  self.property.selected = property
  self.property.needScroll = false
  if property ~= nil then
    self.property.needScroll = true
    self.selection.offset = property:GetOffset()
    self.selection.size = property:GetTypeSize()
  end
  self:Emit("OffsetSelected", self.selection.offset)
end

function MemoryController:Reset()
  self.target = nil
  self.frames = {}
  self.frameIndex = 0
  self.frame = nil
  self.view = nil
  self.views = {}
  self.selection.offset = -1
  self:ResetAddressForm()

  self.properties = {}
  self.property.hovered = nil
  self.property.selected = nil
  self.property.needScroll = false

  self.heatMap = {}
  self.heatMax = 0
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

---@param bytes string[]
---@return string[]
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

function MemoryController:BuildHeatMap()
  if #self.frames < 2 then
    return {}, 0
  end
  local heatMap = {}
  local prevFrame = self.frames[1]
  local prevView = prevFrame:GetBuffer()

  for i = 1, #prevView do
    heatMap[i] = 0
  end
  local heatMax = 0

  for i = 2, #self.frames do
    local frame = self.frames[i]
    local frameView = frame:GetBuffer()

    for j, byte in ipairs(frameView) do
      if byte - prevView[j] ~= 0 then
        heatMap[j] = heatMap[j] + 1
        if heatMap[j] > heatMax then
          heatMax = heatMap[j]
        end
      end
    end
    prevFrame = frame
    prevView = frameView
  end
  return heatMap, heatMax
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

function MemoryController:StartPlayer()
  if self.isPlaying then
    return
  end
  self:StartInterval(0.200, "OnPlayerTick")
  self.isPlaying = true
end

function MemoryController:OnPlayerTick()
  if not self.isPlaying then
    return
  end
  self:NextFrame()
end

function MemoryController:StopPlayer()
  if not self.isPlaying then
    return
  end
  self:StopInterval("OnPlayerTick")
  self.isPlaying = false
end

---@return boolean
function MemoryController:HasFrames()
  return #self.frames > 0
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
  self.heatMap = {}
  self.heatMax = 0
  self:Emit("FrameChanged", self.frame)
end

--- @private
function MemoryController:UpdateFrame()
  self.frame = self.frames[self.frameIndex]
  self.view = self.views[self.frameIndex]
  self:Emit("FrameChanged", self.frame)
end

---@param offset number
function MemoryController:Select(offset)
  if self.selection.offset == offset then
    self.selection.offset = -1
  else
    self.selection.offset = offset
  end
  self:Emit("OffsetSelected", self.selection.offset)
end

function MemoryController:ScrolledToProperty()
  self.property.needScroll = false
end

function MemoryController:SubmitAddressForm()
  local form = self.addressForm

  self:Emit("AddressFormSent", form.name, form.type, form.address, form.size)
  self:ResetAddressForm()
end

return MemoryController
