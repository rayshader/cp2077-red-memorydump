local View = require_verbose("Views/View")

---@class ToolsView : View, ToolsViewModel
---@field canSearchHandles boolean
---
local ToolsView = View:new()

---@param controller ToolsController
---@param theme Theme
---@overload fun(controller: Controller, theme: Theme): ToolsView
function ToolsView:new(controller, theme)
  local obj = View:new(controller, theme)
  setmetatable(obj, { __index = ToolsView })
  return obj
end

function ToolsView:Draw()
  View.Draw(self)

  ImGui.TextDisabled("TOOLS")
  ImGui.Separator()
  ImGui.Spacing()

  ImGui.AlignTextToFramePadding()
  ImGui.Text("Search for handles:")
  ImGui.SameLine()
  if not self.canSearchHandles then
    ImGui.Text("you must select a target and capture at least a frame.")
  end
  if self.canSearchHandles and ImGui.Button(" Run ") then
    self:Call("SearchHandles")
  end
  if self.canSearchHandles and self.clearCache and ImGui.IsItemHovered() then
    ImGui.SetTooltip("This will fetch all known ISerializable, about ~2 millions. This will freeze the game for a " ..
                     "minute or more. Handles will be put in cache for next attempts, unless you \"reload all mods\".")
  end
  local size = #self.results

  if self.searched and size == 0 then
    ImGui.TextWrapped("Could not find any handles. Either none exists or it could not be detected with current " ..
                      "algorithm.")
  elseif self.searched and size > 0 then
    ImGui.TextWrapped(
      string.format("Found %d handles. You can see them in section PROPERTIES. All of them are defined as " ..
                    "`handle` but a manual check is required to deduce `whandle` / `handle`. Moreover the type " ..
                    "might not be accurate, as declared type could be a parent in the inheritance tree.", size))
  end

  ImGui.Dummy(0, 12)

  ImGui.TextDisabled("Work in progress...")
  --[[
  ImGui.Text("Search for a value:")

  ImGui.AlignTextToFramePadding()
  ImGui.Text("Type")

  ImGui.SameLine()

  local typeIndex = self.typeIndex

  typeIndex = ImGui.Combo("##searchType", typeIndex, self.types, #self.types)
  if typeIndex ~= self.typeIndex then
    self:Call("SelectType", typeIndex)
  end

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
