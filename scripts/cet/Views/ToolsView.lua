local View = require_verbose("Views/View")

---@class ToolsView : View, ToolsViewModel
---@field canSearchHandles boolean
---@field hasRedSocket boolean
---@field isConnected boolean
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

  local width, height = ImGui.GetContentRegionAvail()

  ImGui.TextDisabled("TOOLS")
  ImGui.Separator()
  ImGui.Spacing()

  if ImGui.BeginTabBar("##tools") then
    if ImGui.BeginTabItem("Search") then
      ImGui.Spacing()

      self:DrawSearchTab()
      ImGui.EndTabItem()
    end

    if ImGui.BeginTabItem("Socket") then
      ImGui.Spacing()

      self:DrawSocketTab(width, height)
      ImGui.EndTabItem()
    end

    ImGui.EndTabBar()
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

function ToolsView:DrawSearchTab()
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
end

function ToolsView:DrawSocketTab(width, height)
  if not self.hasRedSocket then
    ImGui.Text("RedSocket is not installed.")
    ImGui.Text("See https://github.com/rayshader/cp2077-red-socket")
    return
  end
  local flagReadOnly = 0

  if self.isConnected then
      flagReadOnly = ImGuiInputTextFlags.ReadOnly
  end

  ImGui.PushItemWidth((width - 24 - 80 - 36) / 2)
  local ipAddress = ImGui.InputTextWithHint("##ipAddress", "IP Address", self.ipAddress, 17, flagReadOnly)
  ImGui.PopItemWidth()
  if ipAddress ~= self.ipAddress then
    self:Call("SetIpAddress", ipAddress)
  end

  ImGui.SameLine()

  ImGui.PushItemWidth((width - 24 - 80 - 36) / 2)
  local port = tostring(self.port)
  if self.port < 1024 then
    port = ""
  end
  port = ImGui.InputTextWithHint("##port", "Port", port, 6,
    flagReadOnly + ImGuiInputTextFlags.CharsDecimal + ImGuiInputTextFlags.CharsNoBlank)
  ImGui.PopItemWidth()
  if port ~= tostring(self.port) then
    self:Call("SetPort", port)
  end

  ImGui.SameLine()

  if not self.isConnected and ImGui.Button("Connect", 80, 0) then
    self:Call("Connect")
  elseif self.isConnected and ImGui.Button("Disconnect", 80, 0) then
    self:Call("Disconnect")
  end

  ImGui.SameLine()

  local status
  if self.isConnected then
    status = self.theme.colors.success
  else
    status = self.theme.colors.error
  end
  ImGui.ColorEdit3("##status", status, ImGuiColorEditFlags.NoAlpha + ImGuiColorEditFlags.NoPicker + ImGuiColorEditFlags.NoInputs + ImGuiColorEditFlags.NoTooltip + ImGuiColorEditFlags.NoDragDrop)

  ImGui.Spacing()

  if ImGui.BeginChild("##console", width - 24, 0.33 * height, true, ImGuiWindowFlags.HorizontalScrollbar) then
    for _, line in ipairs(self.console) do
      ImGui.Text(line)
    end
    if ImGui.GetScrollY() >= ImGui.GetScrollMaxY() then
       ImGui.SetScrollHereY(1.0)
    end
    ImGui.EndChild()
  end

  ImGui.Spacing()

  ImGui.PushItemWidth(width - 24)
  local command = ImGui.InputTextWithHint("##command", "Enter to send command", self.command, 1024)
  ImGui.PopItemWidth()
  if command ~= self.command then
    self:Call("SetCommand", command)
  end
  if ImGui.IsKeyPressed(ImGuiKey.Enter) then
    self:Call("SendCommand")
  end
end

return ToolsView
