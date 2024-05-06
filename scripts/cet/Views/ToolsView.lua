local View = require_verbose("Views/View")

local ToolsView = View:new()

function ToolsView:new(controller, theme)
  local obj = View:new(controller, theme)
  setmetatable(obj, { __index = ToolsView })
  return obj
end

function ToolsView:Draw()
  ImGui.TextDisabled("TOOLS")
  ImGui.Separator()
  ImGui.Spacing()

  ImGui.TextDisabled("Work in progress...")
  --[[
  ImGui.Text("Search for a value:")

  ImGui.AlignTextToFramePadding()
  ImGui.Text("Type")

  ImGui.SameLine()

  local typeIndex = self.controller.typeIndex

  typeIndex = ImGui.Combo("##searchType", typeIndex, self.controller.types, #self.controller.types)
  self.controller:SelectType(typeIndex)

  ImGui.AlignTextToFramePadding()
  ImGui.Text("Value")

  ImGui.SameLine()

  local valueIntValue = 0
  valueIntValue = ImGui.InputInt("##valueInt", valueIntValue, 1, 10)

  ImGui.AlignTextToFramePadding()
  ImGui.Text("Value")

  ImGui.SameLine()

  local valueBoolValue = false
  valueBoolValue = ImGui.Checkbox("##valueBool", valueBoolValue)

  ImGui.AlignTextToFramePadding()
  ImGui.Text("Value")

  ImGui.SameLine()

  local valueTextText = ""
  valueTextText = ImGui.InputText("##valueText", valueTextText, 256)

  ImGui.Spacing()

  if ImGui.Button("Search", -1, 0) then
    -- TODO
  end
  --]]
end

return ToolsView
