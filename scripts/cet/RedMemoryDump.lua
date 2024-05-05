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

local RedMemoryDump = {}

function RedMemoryDump:new()
  local obj = {}
  setmetatable(obj, { __index = RedMemoryDump })

  -- MVC
  obj.signal = Signal:new()
  obj.controllers = {
    targets = TargetsController:new(obj.signal),
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
    name = "RedMemoryDump",
    version = "0.1.0",
    api = {
      AddTarget = function(target) obj.controllers.targets:AddTarget(target) end
    }
  }
end

function RedMemoryDump:Hook()
  print("[RedMemoryDump] Hook")
end

function RedMemoryDump:Start()
  print("[RedMemoryDump] Start")
end

--[[
function RedMemoryDump:Update(delta)
end
--]]

function RedMemoryDump:Stop()
  print("[RedMemoryDump] Stop")
end

return RedMemoryDump
