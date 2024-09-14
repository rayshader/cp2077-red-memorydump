local View = require_verbose("Views/View")

---@class TargetsView : View
---@field controller TargetsController
local TargetsView = View:new()

---@param controller TargetsController
---@param theme Theme
---@overload fun(controller: Controller, theme: Theme): TargetsView
function TargetsView:new(controller, theme)
  local obj = View:new(controller, theme)
  setmetatable(obj, { __index = TargetsView })
  return obj
end

function TargetsView:ListTargets()
  local targets = { "<None>" }

  for _, target in ipairs(self.controller.targets) do
    table.insert(targets, target:GetName())
  end
  return targets
end

function TargetsView:Draw()
  ImGui.TextDisabled("TARGETS")
  ImGui.Separator()
  ImGui.Spacing()

  ImGui.AlignTextToFramePadding()
  ImGui.Text("Track")

  ImGui.SameLine()

  local targets = self:ListTargets()
  local targetIndex = self.controller.targetIndex

  targetIndex = ImGui.Combo("##target", targetIndex, targets, #targets)
  self.controller:SelectTarget(targetIndex)

  ImGui.SameLine()

  if ImGui.Button("Remove") then
    self.controller:RemoveTarget()
  end
  if ImGui.IsItemHovered() then
    ImGui.SetTooltip("Remove selected target from tracking.")
  end
  local target = self.controller.target

  if target ~= nil then
    ImGui.Text("Type: " .. NameToString(target:GetType()))

    local size = target:GetSize()

    if target:IsSizeLocked() then
      ImGui.Text("Size: " .. tostring(size) .. " bytes")
    else
      ImGui.AlignTextToFramePadding()
      ImGui.Text("Size")

      ImGui.SameLine()
      size = ImGui.InputInt("##size", size, 4, 16)
      if size < 4 then
        size = 4
      end
      target:SetSize(size)
    end

    ImGui.Spacing()
  end

  if ImGui.Button("Add target", -1, 0) then
    self.controller:AddCustomTarget()
  end
  if ImGui.IsItemHovered() then
    ImGui.SetTooltip("Define behavior in RedMemoryDump/AddCustomTarget.lua")
  end

  if ImGui.Button("Capture", -1, 0) then
    self.controller:Capture()
  end
  if ImGui.IsItemHovered() then
    ImGui.SetTooltip("Dump a new frame.")
  end
end

return TargetsView
