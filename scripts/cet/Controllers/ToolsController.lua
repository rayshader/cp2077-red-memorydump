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
---
---@field socket Socket?
---@field ipAddress string
---@field port integer
---@field command string
---@field console string[]

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

  obj.socket = nil
  obj.ipAddress = ""
  obj.port = -1
  obj.command = ""
  obj.console = {}

  obj:Bind("CanSearchHandles", "canSearchHandles")
  obj:Bind("HasRedSocket", "hasRedSocket")
  obj:Bind("IsConnected", "isConnected")

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

  local RedSocket = GetMod("RedSocket")

  if RedSocket ~= nil then
    local this = self
    self.socket = RedSocket.createSocket()
    self.socket:RegisterListener(function(command) this:OnCommand(command) end, function() this:OnDisconnection() end)
  end

  self:StartInterval(10.0, "OnCacheRevoked")
end

---@return boolean
function ToolsController:CanSearchHandles()
  return self.target ~= nil and self.frame ~= nil
end

---@return boolean
function ToolsController:HasRedSocket()
  return self.socket ~= nil
end

---@return boolean
function ToolsController:IsConnected()
  return self.socket ~= nil and self.socket:IsConnected()
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

-- Tab: Search

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

-- Tab: Socket

---@param ipAddress string
function ToolsController:SetIpAddress(ipAddress)
  if #ipAddress < 7 or #ipAddress > 16 then
    return
  end
  self.ipAddress = ipAddress
end

---@param port any?
function ToolsController:SetPort(port)
  if port == nil or #port == 0 then
    return
  end
  port = math.floor(tonumber(port))
  if port < 1024 or port > 49151 then
    return
  end
  self.port = port
end

function ToolsController:Connect()
  if self:IsConnected() then
    return
  end
  if #self.ipAddress < 7 or #self.ipAddress > 16 or self.port < 1024 or self.port > 49151 then
    return
  end
  if not self.socket:Connect(self.ipAddress, self.port) then
    table.insert(self.console, string.format("# Failed to connect on %s:%d.", self.ipAddress, self.port))
    table.insert(self.console, "# Is the server running?")
    return
  end
  table.insert(self.console, string.format("# Connected to %s:%d", self.ipAddress, self.port))
end

function ToolsController:Disconnect()
  if not self:IsConnected() then
    return
  end
  self.socket:Disconnect()
end

---@param command string?
function ToolsController:SetCommand(command)
  if command == nil then
    return
  end
  self.command = command
end

function ToolsController:SendCommand()
  if not self:IsConnected() or #self.command == 0 then
    return
  end
  self.socket:SendCommand(self.command)
  table.insert(self.console, "> " .. self.command)
  self.command = ""
end

---@param command string
function ToolsController:OnCommand(command)
  table.insert(self.console, command)
end

function ToolsController:OnDisconnection()
  table.insert(self.console, "# Server closed.")
end

return ToolsController
