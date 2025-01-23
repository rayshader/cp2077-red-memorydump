local View = require_verbose("Views/View")

---@class OptionsView : View, OptionsViewModel
local OptionsView = View:new()

---@param controller OptionsController
---@param theme Theme
---@overload fun(controller: Controller, theme: Theme): OptionsView
function OptionsView:new(controller, theme)
  local obj = View:new(controller, theme)
  setmetatable(obj, { __index = OptionsView })
  return obj
end

function OptionsView:Draw()
  View.Draw(self)

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

    ImGui.AlignTextToFramePadding()
    ImGui.Text("Show heat map")
    --[[
    ImGui.AlignTextToFramePadding()
    ImGui.Text("Show duplicates")
    --]]
    ImGui.TextDisabled("Work in progress...")

    ImGui.EndChild()
  end

  ImGui.SameLine()

  if ImGui.BeginChild("Fields", 0, 0, false) then
    local hideProperties = self.hideProperties

    hideProperties = ImGui.Checkbox("##hideProperties", hideProperties)
    if hideProperties ~= self.hideProperties then
      self:Call("SetHideProperties", hideProperties)
    end
    if ImGui.IsItemHovered() then
      ImGui.SetTooltip("Help to focus only on unknown regions of memory.")
    end
    local showHeatMap = self.showHeatMap

    showHeatMap = ImGui.Checkbox("##showHeatMap", showHeatMap)
    if showHeatMap ~= self.showHeatMap then
      self:Call("SetHeatMap", showHeatMap)
    end
    if ImGui.IsItemHovered() then
      ImGui.SetTooltip("Show frequency of changes with gradient colors.")
    end

    ImGui.SameLine()

    ImGui.ColorEdit3("##heat", {0, 1, 0.25}, ImGuiColorEditFlags.NoAlpha + ImGuiColorEditFlags.NoPicker + ImGuiColorEditFlags.NoInputs + ImGuiColorEditFlags.NoTooltip + ImGuiColorEditFlags.NoDragDrop)
    --[[
    local showDuplicates = self.showDuplicates

    showDuplicates = ImGui.Checkbox("##showDuplicates", showDuplicates)
    if showDuplicates ~= self.showDuplicates then
      self:Call("SetDuplicates", showDuplicates)
    end
    if ImGui.IsItemHovered() then
      ImGui.SetTooltip("Highlight regions of memory identical to current selection.")
    end
    --]]

    ImGui.EndChild()
  end

  ImGui.EndChild()
end

return OptionsView
