local Controller = require_verbose("Controllers/Controller")
local MemorySearchHandle = require_verbose("Data/MemorySearchHandle")
local Utils = require_verbose("Utils")

---@class ToolsViewModel
---@field types string[]
---@field typeIndex number
---@field type string?
---
---@field target MemoryTarget?
---@field frame MemoryFrame?
---@field searched boolean
---@field clearCache boolean
---@field results MemorySearchHandle[]

---@class ToolsController : Controller, ToolsViewModel
local ToolsController = Controller:new()

---@param signal Signal
function ToolsController:new(signal)
  local obj = Controller:new("tools", signal)
  setmetatable(obj, { __index = ToolsController })

  obj.types = { "Int32", "Int64", "Uint32", "Uint64", "Float", "Double", "String", "CName" }
  obj.typeIndex = 1
  obj.type = {}

  obj.target = {}
  obj.frame = {}
  obj.searched = {}
  obj.clearCache = {}
  obj.results = {}

  obj:Bind("CanSearchHandles", "canSearchHandles")

  obj:Listen("targets", "OnTargetSelected")
  obj:Listen("memory", "OnFrameChanged")
  return obj
end

function ToolsController:Load()
  Controller.Load(self)

  self.target = nil
  self.frame = nil
  self.clearCache = true
  self.searched = false

  self:StartInterval(10.0, "OnCacheRevoked")
end

---@return boolean
function ToolsController:CanSearchHandles()
  return self.target ~= nil and self.frame ~= nil
end

---@private
---@param target MemoryTarget?
function ToolsController:OnTargetSelected(target)
  self.target = target
  self.results = {}
  self.searched = false
end

---@private
---@param frame MemoryFrame?
function ToolsController:OnFrameChanged(frame)
  self.frame = frame
  self.results = {}
  self.searched = false
end

---@private
function ToolsController:OnCacheRevoked()
  self.clearCache = true
end

---@param index number
function ToolsController:SelectType(index)
  if self.typeIndex == index and self.type ~= nil then
    return
  end
  self.typeIndex = index
  self.type = self.types[index]
  self:Emit("TypeChanged", self.type)
end

function ToolsController:SearchHandles()
  if not self:CanSearchHandles() then
    return
  end
  if self.searched then
      return
  end
  local results = self.target:SearchHandles(self.frame, self.clearCache)

  self.results = MemorySearchHandle.ToTable(results)
  self.searched = true
  self.clearCache = false
  self:Emit("HandlesFound", Utils.Copy(self.results))
end

return ToolsController
