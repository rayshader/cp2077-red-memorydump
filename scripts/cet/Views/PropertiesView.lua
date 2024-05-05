local PropertiesView = {}

function PropertiesView:new(controller, theme)
  local obj = {}
  setmetatable(obj, { __index = PropertiesView })

  obj.controller = controller
  obj.theme = theme
  return obj
end

function PropertiesView:Draw()
  ImGui.TextDisabled("PROPERTIES")
  ImGui.Separator()
  ImGui.Spacing()

  if not ImGui.BeginChild("PropertiesContainer", 0, 0, false) then
    ImGui.EndChild()
    return
  end
  -- ##Table
  ImGui.Columns(3, "##Table")
  ImGui.Separator()
  ImGui.Text("Offset")
  ImGui.NextColumn()

  ImGui.Text("Name")
  ImGui.NextColumn()

  ImGui.Text("Type")
  ImGui.NextColumn()

  ImGui.Separator()

  if #self.controller.properties == 0 then
    ImGui.Text("")
    ImGui.NextColumn()

    ImGui.Text("")
    ImGui.NextColumn()

    ImGui.Text("")
    ImGui.NextColumn()
  end
  for i, property in ipairs(self.controller.properties) do
    local color = nil

    --[[ FIX ME
    if self.controller.hovered.index ~= nil then
      color = self.theme.colors.hovered
    elseif self.controller.selected.index ~= nil then
      color = self.theme.colors.selected
    end
    --]]
    if color ~= nil then
      ImGui.PushStyleColor(ImGuiCol.Text, color[1], color[2], color[3], color[4])
    end
    local offset = string.format("0x%X", property:GetOffset())

    ImGui.Text(offset)
    self:OnItem(i)
    ImGui.NextColumn()

    local color = self.theme.colors.selected

    ImGui.TextColored(color[1], color[2], color[3], color[4], property:GetName())
    self:OnItem(i)
    ImGui.NextColumn()

    ImGui.Text(NameToString(property:GetTypeName()))
    self:OnItem(i)
    ImGui.NextColumn()

    if i < #self.controller.properties then
      ImGui.Separator()
    end

    if color ~= nil then
      ImGui.PopStyleColor()
    end
  end
  ImGui.Columns(1)
  ImGui.Separator()
  -- ##Table

  ImGui.EndChild()
  if ImGui.IsItemHovered() then
    self.controller:HoverProperty(nil)
  end
end

function PropertiesView:OnItem(i)
  if ImGui.IsItemHovered() then
    self.controller:HoverProperty(i)
  elseif ImGui.IsItemClicked() then
    self.controller:SelectProperty(i)
  end
end

return PropertiesView
