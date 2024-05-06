local View = require_verbose("Views/View")

local PropertiesView = View:new()

function PropertiesView:new(controller, theme)
  local obj = View:new(controller, theme)
  setmetatable(obj, { __index = PropertiesView })
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

    if self.controller.hovered.index == i then
      color = self.theme.colors.hovered
    elseif self.controller.selected.index == i then
      color = self.theme.colors.selected
    end
    if color ~= nil then
      ImGui.PushStyleColor(ImGuiCol.Text, color[1], color[2], color[3], color[4])
    end
    local offset = string.format("0x%X", property:GetOffset())

    ImGui.Text(offset)
    self:OnItem(i)
    ImGui.NextColumn()

    ImGui.Text(property:GetName())
    self:OnItem(i)
    ImGui.NextColumn()

    ImGui.Text(NameToString(property:GetTypeName()))
    self:OnItem(i)
    ImGui.NextColumn()

    if color ~= nil then
      ImGui.PopStyleColor()
    end

    if i < #self.controller.properties then
      ImGui.Separator()
    end
  end
  ImGui.Columns(1)
  ImGui.Separator()
  -- ##Table

  ImGui.EndChild()
end

function PropertiesView:OnItem(i)
  if ImGui.IsItemHovered() then
    self.controller:HoverProperty(i)
  end
  if ImGui.IsItemClicked() then
    self.controller:SelectProperty(i)
  end
end

return PropertiesView
