local View = require_verbose("Views/View")
local Utils = require_verbose("Utils")

---@class MemoryView : View
---@field controller MemoryController
local MemoryView = View:new()

---@param controller MemoryController
---@param theme Theme
---@overload fun(controller: Controller, theme: Theme): MemoryView
function MemoryView:new(controller, theme)
  local obj = View:new(controller, theme)
  setmetatable(obj, { __index = MemoryView })
  return obj
end

function MemoryView:Draw()
  ImGui.TextDisabled("MEMORY")
  ImGui.Separator()
  ImGui.Spacing()

  ImGui.AlignTextToFramePadding()
  ImGui.Text("Frame:")
  ImGui.SameLine()

  local frameIndex = self.controller.frameIndex
  local minIndex = 1

  if not self.controller:HasFrames() then
    minIndex = 0
  end
  frameIndex = ImGui.SliderInt("##frameIndex", frameIndex, minIndex, #self.controller.frames, "%d")
  self.controller:SelectFrame(frameIndex)

  if self.controller:HasFrames() then
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
  
    ImGui.SameLine()
  
    if ImGui.Button(" X ", -1, 0) then
      self.controller:DeleteFrame()
    end
    if ImGui.IsItemHovered() then
      ImGui.SetTooltip("Delete frame")
    end
  end

  ImGui.Spacing()

  self:DrawFrame()
end

function MemoryView:DrawFrame()
  local frameRate = self.controller.frameRate
  local elapsedTime = self.controller.elapsedTime

  if elapsedTime > frameRate then
    ImGui.Text("Elapsed time: ")
    ImGui.SameLine()
    local color = self.theme.colors.error

    ImGui.TextColored(color[1], color[2], color[3], color[4], string.format("%.3f", elapsedTime) .. " s")
  else
    ImGui.Text(" ")
  end

  ImGui.Spacing()

  ImGui.Text("          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F")
  local _, height = ImGui.GetContentRegionAvail()

  if not ImGui.BeginChild("MemoryContainer", 0, 0.6 * height, false) then
    ImGui.EndChild()
    return
  end
  local view = self.controller.view

  if view == nil then
    ImGui.Text("No data to dump...")
    ImGui.EndChild()
    return
  end
  local offset = 0
  local hover = self.controller.hover
  local selection = self.controller.selection

  self.controller.start = os.clock()
  self.controller:ResetHover()
  for _, byte in ipairs(view) do
    if offset % 16 == 0 then
      if offset ~= 0 then
        ImGui.NewLine()
      end
      ImGui.AlignTextToFramePadding()
      ImGui.Text(string.format("%06X  ", offset))
      ImGui.SameLine()
    end
    ---@type number[]?
    local color = nil

    if Utils.IsInRange(offset, hover.offset, hover.size) then
      color = self.theme.colors.hovered
      if self.controller.property.needScroll then
        self.controller.property.needScroll = false
        ImGui.SetScrollHereY()
      end
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
    if self.controller.isHovered and ImGui.IsItemHovered() then
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
  self.controller.isHovered = ImGui.IsItemHovered()
  self.controller.elapsedTime = os.clock() - self.controller.start
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
