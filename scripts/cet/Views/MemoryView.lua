local Utils = require_verbose("Utils")

local MemoryView = {}

function MemoryView:new(controller, theme)
  local obj = {}
  setmetatable(obj, { __index = MemoryView })

  obj.controller = controller
  obj.theme = theme
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
    local property = Utils.FindProperty(self.controller.properties, offset)

    if property ~= nil and not Utils.IsTypeUnknown(property:GetTypeName()) then
      byte = "__"
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
    end
    ImGui.SameLine()
    offset = offset + 1
  end

  ImGui.EndChild()
end

return MemoryView
