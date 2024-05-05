local TargetsView = {}

function TargetsView:new(controller)
  local obj = {}
  setmetatable(obj, { __index = TargetsView })

  obj.controller = controller
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
    ImGui.AlignTextToFramePadding()
    ImGui.Text("Size")

    ImGui.SameLine()

    local size = target:GetSize()

    size = ImGui.InputInt("##size", size, 1, 8)
    if not target:IsLocked() then
      target.size = size
    end

    ImGui.Spacing()
  end

  if ImGui.Button("Add custom target", -1, 0) then
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
