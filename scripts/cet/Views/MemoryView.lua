local View = require_verbose("Views/View")
local Utils = require_verbose("Utils")

---@class MemoryView : View, MemoryViewModel
---@field hasFrames boolean
---
---@field isHovered boolean
---@field hover {offset: number, size: number}
local MemoryView = View:new()

---@param controller MemoryController
---@param theme Theme
---@overload fun(controller: Controller, theme: Theme): MemoryView
function MemoryView:new(controller, theme)
  local obj = View:new(controller, theme)
  setmetatable(obj, { __index = MemoryView })

  obj.isHovered = false
  obj.hover = {
    offset = -1,
    size = 1
  }
  return obj
end

function MemoryView:Draw()
  View.Draw(self)

  ImGui.TextDisabled("MEMORY")
  ImGui.Separator()
  ImGui.Spacing()

  ImGui.AlignTextToFramePadding()
  ImGui.Text("Frame:")
  ImGui.SameLine()

  local frameIndex = self.frameIndex
  local minIndex = 1

  if not self.hasFrames then
    minIndex = 0
  end
  frameIndex = ImGui.SliderInt("##frameIndex", frameIndex, minIndex, #self.frames, "%d")
  if frameIndex ~= self.frameIndex then
    self:Call("SelectFrame", frameIndex)
  end

  if self.hasFrames then
    ImGui.SameLine()
    local isPlaying = self.isPlaying

    if not isPlaying then
      if ImGui.ArrowButton("##play", ImGuiDir.Right) then
        self:Call("StartPlayer")
      end
      if ImGui.IsItemHovered() then
        ImGui.SetTooltip("Play frames")
      end

      ImGui.SameLine()
  
      if ImGui.Button(" X ", -1, 0) and self.hasFrames then
        self:Call("DeleteFrame")
      end
      if ImGui.IsItemHovered() then
        ImGui.SetTooltip("Delete frame")
      end
    else
      if ImGui.Button("Stop") then
        self:Call("StopPlayer")
      end
      if ImGui.IsItemHovered() then
        ImGui.SetTooltip("Stop playing frames")
      end
    end
  end

  ImGui.Spacing()

  self:DrawFrame()
end

function MemoryView:DrawFrame()
  ImGui.Text(" ")
  ImGui.Spacing()

  ImGui.Text("          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F")
  local _, height = ImGui.GetContentRegionAvail()

  if not ImGui.BeginChild("MemoryContainer", 0, 0.6 * height, false) then
    ImGui.EndChild()
    return
  end
  local view = self.view

  if view == nil then
    ImGui.Text("No data to dump...")
    ImGui.EndChild()
    return
  end
  local heatMap = self.heatMap
  local offset = 0
  local hover = self.hover
  local selection = self.selection

  if not self.isHovered and self.property.hovered == nil then
    self.hover.offset = -1
  end
  for i, byte in ipairs(view) do
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

    if self.showHeatMap and #heatMap > 0 and heatMap[i] > 0 then
      local heat = 1.0 - (heatMap[i] / self.heatMax)

      color = {
          heat,
          1,
          heat * 3.0 / 4.0 + 0.25,
          1
      }
    end

    if Utils.IsInRange(offset, hover.offset, hover.size) then
      color = self.theme.colors.hovered
    elseif Utils.IsInRange(offset, selection.offset, selection.size) then
      if self.property.needScroll then
        self:Call("ScrolledToProperty")
        ImGui.SetScrollHereY()
      end
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
    if self.isHovered and ImGui.IsItemHovered() and self.hover.offset ~= offset then
      if self.hover.offset ~= offset then
        self.hover.offset = offset
      end
    end
    if ImGui.IsItemClicked() then
      self:Call("Select", offset)
    elseif ImGui.IsItemClicked(ImGuiMouseButton.Right) then
      local form = self.addressForm

      form.offset = offset
      form.address = self.frame:GetUint64(offset)
      form.name = string.format("Address 0x%X", form.address)
      form.type = "void*"
      ImGui.OpenPopup("##addressForm")
    end
    ImGui.SameLine()
    offset = offset + 1
  end

  self:DrawAddressForm()

  ImGui.EndChild()
  self.isHovered = ImGui.IsItemHovered()
end

function MemoryView:DrawAddressForm()
  local form = self.addressForm

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
      self:Call("ResetAddressForm")
    end

    ImGui.SameLine()
    ImGui.Dummy(12, 0)
    ImGui.SameLine()

    if ImGui.Button("Add target", buttonWidth, 0) then
      self:Call("SubmitAddressForm")
    end
    ImGui.EndPopup()
  end
end

return MemoryView
