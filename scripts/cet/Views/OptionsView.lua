local View = require_verbose("Views/View")

local OptionsView = View:new()

function OptionsView:new(controller, theme)
  local obj = View:new(controller, theme)
  setmetatable(obj, { __index = OptionsView })
  return obj
end

function OptionsView:Draw()
  ImGui.TextDisabled("OPTIONS")
  ImGui.Separator()
  ImGui.Spacing()

  if not ImGui.BeginChild("Options", 0, 84, false) then
    ImGui.EndChild()
    return
  end
  local width = ImGui.GetContentRegionAvail()

  if ImGui.BeginChild("Labels", 0.5 * width, 0, false) then
    ImGui.AlignTextToFramePadding()
    ImGui.Text("Hide known properties")

    --[[
    ImGui.AlignTextToFramePadding()
    ImGui.Text("Show heat map")
    --]]

    ImGui.AlignTextToFramePadding()
    ImGui.Text("Show duplicates")

    ImGui.EndChild()
  end

  ImGui.SameLine()

  if ImGui.BeginChild("Fields", 0, 0, false) then
    local hideProperties = self.controller.hideProperties

    hideProperties = ImGui.Checkbox("##hideProperties", hideProperties)
    self.controller:SetProperties(hideProperties)
    if ImGui.IsItemHovered() then
      ImGui.SetTooltip("Help to focus only on unknown regions of memory.")
    end
    --[[
    local showHeatMap = self.controller.showHeatMap

    showHeatMap = ImGui.Checkbox("##showHeatMap", showHeatMap)
    self.controller:SetHeatMap(showHeatMap)
    if ImGui.IsItemHovered() then
      ImGui.SetTooltip("Show frequency of changes with gradient colors.")
    end
    --]]
    local showDuplicates = self.controller.showDuplicates

    showDuplicates = ImGui.Checkbox("##showDuplicates", showDuplicates)
    self.controller:SetDuplicates(showDuplicates)
    if ImGui.IsItemHovered() then
      ImGui.SetTooltip("Highlight regions of memory identical to current selection.")
    end

    ImGui.EndChild()
  end

  ImGui.EndChild()
end

return OptionsView
