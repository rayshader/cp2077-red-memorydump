local View = require_verbose("Views/View")
local Utils = require_verbose("Utils")

local MemoryView = View:new()

function MemoryView:new(controller, theme)
  local obj = View:new(controller, theme)
  setmetatable(obj, { __index = MemoryView })
  return obj
end

function MemoryView:Draw()
  ImGui.TextDisabled("MEMORY")
  ImGui.Separator()
  ImGui.Spacing()

  ImGui.Text("Frame:")

  ImGui.SameLine()

  local frameIndex = self.controller.frameIndex

  frameIndex = ImGui.SliderInt("##frameIndex", frameIndex, 1, #self.controller.frames, "%d")
  self.controller:SelectFrame(frameIndex)

  ImGui.SameLine()

  if ImGui.ArrowButton("##previousFrame", ImGuiDir.Left) then
    self.controller:PreviousFrame()
  end
  if ImGui.IsItemHovered() then
    ImGui.SetTooltip("Previous frame")
  end

  ImGui.SameLine()

  if ImGui.ArrowButton("##nextFrame", ImGuiDir.Right) then
    self.controller:NextFrame()
  end
  if ImGui.IsItemHovered() then
    ImGui.SetTooltip("Next frame")
  end

  ImGui.Spacing()

  self:DrawFrame(self.controller.frame)
end

function MemoryView:DrawFrame(frame)
  local bytes = nil

  if frame ~= nil then
    bytes = frame:GetBufferView()
  end
  ImGui.Text("          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F")
  local _, height = ImGui.GetContentRegionAvail()

  if not ImGui.BeginChild("MemoryContainer", 0, 0.5 * height, false) then
    ImGui.EndChild()
    return
  end
  if frame == nil or bytes == nil then
    ImGui.Text("No data to dump...")
    ImGui.EndChild()
    return
  end
  local offset = 0

  for _, byte in ipairs(bytes) do
    if offset % 16 == 0 then
      if offset ~= 0 then
        ImGui.NewLine()
      end
      ImGui.AlignTextToFramePadding()
      ImGui.Text(string.format("%06X  ", offset))
      ImGui.SameLine()
    end
    if self.controller.hideProperties then
      local property = Utils.FindProperty(self.controller.properties, offset)

      if property ~= nil and not Utils.IsTypeUnknown(property:GetTypeName()) then
        byte = "__"
      end
    end
    local hover = self.controller.hover
    local selection = self.controller.selection
    local color = nil

    if Utils.IsInRange(offset, hover.offset, hover.size) then
      color = self.theme.colors.hovered
    elseif Utils.IsInRange(offset, selection.offset, selection.size) then
      color = self.theme.colors.selected
    end
    ImGui.AlignTextToFramePadding()
    if color ~= nil then
      ImGui.PushStyleColor(ImGuiCol.Text, color[1], color[2], color[3], color[4])
      ImGui.Text(byte)
      ImGui.PopStyleColor()
    else
      ImGui.Text(byte)
    end
    if ImGui.IsItemHovered() then
      self.controller:Hover(offset)
    end
    if ImGui.IsItemClicked() then
      self.controller:Select(offset)
    elseif ImGui.IsItemClicked(ImGuiMouseButton.Right) then
      local form = self.controller.addressForm

      form.offset = offset
      form.address = self.controller.frame:GetUint64(offset)
      form.name = string.format("Address 0x%X", form.address)
      form.type = "void*"
      ImGui.OpenPopup("##addressForm")
    end
    ImGui.SameLine()
    offset = offset + 1
  end

  self:DrawAddressForm()

  ImGui.EndChild()
end

function MemoryView:DrawAddressForm()
  local form = self.controller.addressForm

  if form.offset == nil then
    return
  end
  if ImGui.BeginPopup("##addressForm") then
    ImGui.TextDisabled("ADD TARGET")
    ImGui.Separator()
    ImGui.Spacing()

    ImGui.Text("Use value as a raw address:")

    ImGui.Text("Name:")
    ImGui.SameLine(82)
    form.name = ImGui.InputText("##name", form.name, 64)

    ImGui.Text("Type:")
    ImGui.SameLine(82)
    form.type = ImGui.InputText("##type", form.type, 64)

    ImGui.Text("Address:")
    ImGui.SameLine(82)
    ImGui.Text(string.format("0x%X", form.address))

    ImGui.AlignTextToFramePadding()
    ImGui.Text("Size: ")
    ImGui.SameLine(82)
    local size = form.size

    size = ImGui.InputInt("##size", size, 4, 8)
    if size < 4 then
      size = 4
    end
    form.size = size

    ImGui.Spacing()

    local width = ImGui.GetContentRegionAvail()
    local buttonWidth = width / 2 - 18

    if ImGui.Button("Cancel", buttonWidth, 0) then
      self.controller:ResetAddressForm()
    end

    ImGui.SameLine()
    ImGui.Dummy(12, 0)
    ImGui.SameLine()

    if ImGui.Button("Add target", buttonWidth, 0) then
      self.controller:SubmitAddressForm()
    end
    ImGui.EndPopup()
  end
end

return MemoryView
