local View = require_verbose("Views/View")

---@class TargetsView : View
---@field controller TargetsController
---@field rhtTooltip boolean
local TargetsView = View:new()

---@param controller TargetsController
---@param theme Theme
---@overload fun(controller: Controller, theme: Theme): TargetsView
function TargetsView:new(controller, theme)
  local obj = View:new(controller, theme)
  setmetatable(obj, { __index = TargetsView })

  obj.rhtTooltip = true
  return obj
end

---@private
---@return string[]
function TargetsView:ListTargets()
  local targets = { "<None>" }

  for _, target in ipairs(self.controller.targets) do
    table.insert(targets, target:GetName())
  end
  return targets
end

---@private
---@return string[]
function TargetsView:ListWorldObjects()
  local items = {}
  local objects = self.controller:GetWorldObjects()

  for _, object in ipairs(objects) do
    if object.label ~= nil then
      table.insert(items, object.label)
    elseif object.item ~= nil then
      table.insert(items, object.item.description)
    end
  end
  return items
end

---@param width number
function TargetsView:Draw(width)
  local labelWidth = math.floor(0.30 * width)

  if labelWidth < 130 then
    labelWidth = 130
  end
  local inputWidth = width - (labelWidth + 48)

  ImGui.TextDisabled("TARGETS")
  ImGui.Separator()
  ImGui.Spacing()

  ImGui.AlignTextToFramePadding()
  ImGui.Text("Custom target")
  ImGui.SameLine(labelWidth)
  ImGui.PushItemWidth(inputWidth)
  ImGui.InputText("##customTarget", "RedMemoryDump/AddCustomTarget.lua", 64, ImGuiInputTextFlags.ReadOnly)
  ImGui.PopItemWidth()
  ImGui.SameLine()
  if ImGui.Button("Add##custom", -1, 0) then
    self.controller:AddCustomTarget()
  end
  if ImGui.IsItemHovered() then
    ImGui.SetTooltip("Add custom target")
  end

  if not self.controller:HasRHT() and self.rhtTooltip then
    ImGui.Dummy(1, 1)
    ImGui.SameLine(labelWidth)
    ImGui.TextWrapped("Install RedHotTools for more tools.")
    if ImGui.IsItemHovered() then
      self.rhtTooltip = false
    end
  elseif self.controller:HasRHT() then
    ImGui.AlignTextToFramePadding()
    ImGui.Text("World inspector")
    ImGui.SameLine(labelWidth)
    local worldObjects = self:ListWorldObjects()
    local worldObjectIndex = self.controller.worldObjectIndex - 1

    ImGui.PushItemWidth(inputWidth)
    worldObjectIndex = ImGui.Combo("##worldTarget", worldObjectIndex, worldObjects, #worldObjects)
    self.controller:SelectWorldTarget(worldObjectIndex + 1)
    ImGui.PopItemWidth()
    ImGui.SameLine()
    if ImGui.Button("Add##world", -1, 0) then
      self.controller:AddWorldTarget()
    end
    if ImGui.IsItemHovered() then
      ImGui.SetTooltip("Add world target from RHT")
    end

    ImGui.AlignTextToFramePadding()
    ImGui.Text("Ink inspector")
    ImGui.SameLine(labelWidth)
    local widget = self.controller:GetInkWidget()
    local widgetLabel = "<None>"

    if widget ~= nil and IsDefined(widget) then
      widgetLabel = NameToString(widget:GetName()) .. " " .. NameToString(widget:GetClassName())
    end
    ImGui.PushItemWidth(inputWidth)
    ImGui.InputText("##inkTarget", widgetLabel, 256, ImGuiInputTextFlags.ReadOnly)
    ImGui.PopItemWidth()
    ImGui.SameLine()
    if ImGui.Button("Add##ink", -1, 0) then
      print("Fuck?")
      self.controller:AddInkTarget(widget)
    end
    if ImGui.IsItemHovered() then
      ImGui.SetTooltip("Add ink target from RHT")
    end
  end

  ImGui.Dummy(0, 12)

  ImGui.AlignTextToFramePadding()
  ImGui.Text("Track")
  ImGui.SameLine(labelWidth)
  local targets = self:ListTargets()
  local targetIndex = self.controller.targetIndex

  ImGui.PushItemWidth(inputWidth)
  targetIndex = ImGui.Combo("##target", targetIndex, targets, #targets)
  ImGui.PopItemWidth()
  self.controller:SelectTarget(targetIndex)
  ImGui.SameLine()
  if ImGui.Button("X", -1, 0) then
    self.controller:RemoveTarget()
  end
  if ImGui.IsItemHovered() then
    ImGui.SetTooltip("Remove target from tracking.")
  end

  local target = self.controller.target

  if target ~= nil then
    ImGui.AlignTextToFramePadding()
    ImGui.Text("Size")
    ImGui.SameLine(labelWidth)
    local size = target:GetSize()

    if target:IsSizeLocked() then
      ImGui.Text(tostring(size) .. " bytes")
    else
      size = ImGui.InputInt("##size", size, 4, 16)
      if size < 4 then
        size = 4
      end
      target:SetSize(size)
    end
  end

  ImGui.Spacing()

  ImGui.Dummy(1, 1)
  ImGui.SameLine(labelWidth)
  if not self.controller:IsTargetSelected() then
    ImGui.Text("Waiting for a target...")
  elseif self.controller:IsTargetDisposed() then
    local color = self.theme.colors.error

    ImGui.TextColored(color[1], color[2], color[3], color[4], "Target is disposed.")
  else
    if ImGui.Button("Capture", -1, 0) then
      self.controller:Capture()
    end
    if ImGui.IsItemHovered() then
      ImGui.SetTooltip("Dump a new frame.")
    end
  end
end

return TargetsView
