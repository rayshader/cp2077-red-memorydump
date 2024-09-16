local Theme = require_verbose("Theme")

local TargetsView = require_verbose("Views/TargetsView")
local MemoryView = require_verbose("Views/MemoryView")
local DataViewerView = require_verbose("Views/DataViewerView")
local OptionsView = require_verbose("Views/OptionsView")
local ToolsView = require_verbose("Views/ToolsView")
local PropertiesView = require_verbose("Views/PropertiesView")

---@class GUI
---@field private isReady boolean
---@field private isVisible boolean
---@field private theme Theme
---@field private views table<string, View>
local GUI = {}

---@param controllers table<string, Controller>
function GUI:new(controllers)
  local obj = {}
  setmetatable(obj, { __index = GUI })

  obj.isReady = false
  obj.isVisible = false
  obj.theme = Theme:new()
  obj.views = {
    targets = TargetsView:new(controllers.targets, obj.theme),
    memory = MemoryView:new(controllers.memory, obj.theme),
    dataViewer = DataViewerView:new(controllers.dataViewer, obj.theme),
    options = OptionsView:new(controllers.options, obj.theme),
    tools = ToolsView:new(controllers.tools, obj.theme),
    properties = PropertiesView:new(controllers.properties, obj.theme),
  }
  return obj
end

function GUI:Ready()
  self.isReady = true
end

function GUI:Show()
  if not self.isReady then
    return
  end
  self.isVisible = true
end

function GUI:Hide()
  if not self.isReady then
    return
  end
  self.isVisible = false
end

function GUI:Stop()
  self.isVisible = false
end

function GUI:Draw()
  if not self.isVisible then
    return
  end
  ImGui.PushStyleVar(ImGuiStyleVar.WindowMinSize, 640, 520)
  if not ImGui.Begin("RedMemoryDump") then
    ImGui.End()
    return
  end
  local width = ImGui.GetContentRegionAvail()
  local leftWidth = 476
  local rightWidth = width - leftWidth

  ImGui.BeginGroup()
  if ImGui.BeginChild("Left", leftWidth, 0, false) then
    self.views.targets:Draw(leftWidth)
    ImGui.Dummy(0, 12)
    self.views.memory:Draw()
    ImGui.Dummy(0, 12)
    self.views.dataViewer:Draw()
    ImGui.EndChild()
  end

  ImGui.SameLine()
  ImGui.Dummy(12, 0)
  ImGui.SameLine()

  if ImGui.BeginChild("Right", rightWidth, 0, false) then
    self.views.options:Draw()
    ImGui.Dummy(0, 12)
    self.views.tools:Draw()
    ImGui.Dummy(0, 12)
    self.views.properties:Draw()
    ImGui.EndChild()
  end
  ImGui.EndGroup()

  ImGui.End()
end

return GUI
