-- Test
local CustomTarget = require_verbose("AddCustomTarget")

-- Observable
local Signal = require_verbose("Signal")

-- Controllers
local TargetsController = require_verbose("Controllers/TargetsController")
local MemoryController = require_verbose("Controllers/MemoryController")
local DataViewerController = require_verbose("Controllers/DataViewerController")
local OptionsController = require_verbose("Controllers/OptionsController")
local ToolsController = require_verbose("Controllers/ToolsController")
local PropertiesController = require_verbose("Controllers/PropertiesController")

-- Views
local GUI = require_verbose("GUI")

---@class RedMemoryDump
---@field private customTarget table?
---@field private signal Signal
---@field private controllers table<string, Controller>
---@field private gui GUI
---@field private rht RedHotTools
local RedMemoryDump = {}

function RedMemoryDump:new()
  local obj = {}
  setmetatable(obj, { __index = RedMemoryDump })

  if CustomTarget ~= nil and type(CustomTarget) == "table" then
    obj.customTarget = {
      context = {},
      api = CustomTarget
    }
  end

  -- MVC
  obj.signal = Signal:new()
  obj.controllers = {
    targets = TargetsController:new(obj.signal, obj.customTarget),
    memory = MemoryController:new(obj.signal),
    dataViewer = DataViewerController:new(obj.signal),
    options = OptionsController:new(obj.signal),
    tools = ToolsController:new(obj.signal),
    properties = PropertiesController:new(obj.signal)
  }
  obj.gui = GUI:new(obj.controllers)
  return obj
end

function RedMemoryDump:GetApi()
  local obj = self

  return {
    AddTarget = function(target) obj:GetController("targets"):AddTarget(target) end
  }
end

---@param name string
---@return Controller
function RedMemoryDump:GetController(name)
  return self.controllers[name]
end

function RedMemoryDump:Hook()
  if self.customTarget ~= nil then
    self.customTarget.api.OnHook(self.customTarget.context)
  end
  print("[RedMemoryDump] Hook")
end

function RedMemoryDump:Start()
  for _, controller in pairs(self.controllers) do
    controller:Load()
  end
  if self.customTarget ~= nil then
    self.customTarget.api.OnInit(self.customTarget.context)
  end
  self.gui:Ready()
  print("[RedMemoryDump] Start")
end

--[[
---@param delta number
function RedMemoryDump:Update(delta)
end
--]]

function RedMemoryDump:Stop()
  if self.customTarget ~= nil then
    self.customTarget.api.OnShutdown(self.customTarget.context)
  end
  self.gui:Stop()
  for _, controller in pairs(self.controllers) do
    controller:Stop()
  end
  self.signal:Stop()
  print("[RedMemoryDump] Stop")
end

return RedMemoryDump
