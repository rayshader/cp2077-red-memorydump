local View = require_verbose("Views/View")

local DataViewerView = View:new()

function DataViewerView:new(controller, theme)
  local obj = View:new(controller, theme)
  setmetatable(obj, { __index = DataViewerView })
  return obj
end

function DataViewerView:Draw()
  ImGui.TextDisabled("DATA VIEWER")
  ImGui.Separator()
  ImGui.Spacing()

  if not ImGui.BeginChild("DataContainer", 0, 0, false) then
    ImGui.EndChild()
    return
  end
  ImGui.AlignTextToFramePadding()
  ImGui.Text("Type")

  ImGui.SameLine()

  local typeIndex = self.controller.typeIndex

  typeIndex = ImGui.Combo("##type", typeIndex, self.controller.types, #self.controller.types)
  self.controller:SelectType(typeIndex)

  -- ##MemorySpace
  ImGui.Columns(3, "##MemorySpace")
  ImGui.Separator()
  ImGui.Text("Address")
  ImGui.NextColumn()

  ImGui.Text("Offset")
  ImGui.NextColumn()

  ImGui.Text("Size")
  ImGui.NextColumn()

  ImGui.Separator()

  -- Address
  local address = (self.controller.targetAddress or -1) + (self.controller.offset or -1)

  if address < 0 then
    address = "0x????????????????"
  else
    address = string.format("0x%08X", address)
  end
  ImGui.Text(address)
  ImGui.NextColumn()

  -- Offset
  local offset = self.controller.offset

  if offset == nil then
    offset = "?"
  else
    offset = string.format("0x%X", offset)
  end
  ImGui.Text(offset)
  ImGui.NextColumn()

  -- Size ? bytes
  local size = tostring(self.controller.size)

  ImGui.Text(size .. " bytes")
  ImGui.NextColumn()

  ImGui.Columns(1)
  ImGui.Separator()
  -- ##MemorySpace

  self:DrawValue()

  ImGui.EndChild()
end

function DataViewerView:DrawValue()
  local frame = self.controller.frame

  if frame == nil then
    ImGui.Text("Select a frame in memory view...")
    return
  end
  local offset = self.controller.offset

  if offset == nil then
    ImGui.Text("Select an offset in memory view...")
    return
  end
  local type = self.controller.type
  local size = self.controller.size

  if size > 0 and offset + size > frame:GetSize() then
    local color = self.theme.colors.error

    ImGui.TextColored(color[1], color[2], color[3], color[4], "Overflow error: change offset and/or data type...")
    return
  end
  if type == "Bool" then
    ImGui.Text("Value: " .. tostring(frame:GetBool(offset)))
  elseif type == "Int32" then
    ImGui.Text("Value: " .. tostring(frame:GetInt32(offset)))
  elseif type == "Int64" then
    ImGui.Text("Value: " .. tostring(frame:GetInt64(offset)))
  elseif type == "Uint32" then
    ImGui.Text("Value: " .. tostring(frame:GetUint32(offset)))
  elseif type == "Uint64" then
    local value = frame:GetUint64(offset)

    ImGui.Text("Value: " .. tostring(value))
    --[[
    self.raw.size = ImGui.InputInt("Size: ", self.raw.size, 1, 8)
    if ImGui.Button("Track as a raw address", -1, 0) then
      self.listener.currentTracker = self.listener.system:TrackRaw(value, self.raw.size)
      self.raw.size = 0x38
    end
    --]]
  elseif type == "Float" then
    ImGui.Text("Value: " .. tostring(frame:GetFloat(offset)))
  elseif type == "Double" then
    ImGui.Text("Value: " .. tostring(frame:GetDouble(offset)))
  elseif type == "String" then
    ImGui.Text("Value: \"" .. tostring(frame:GetString(offset)) .. "\"")
  elseif type == "CName" then
    ImGui.Text("Value: n\"" .. NameToString(frame:GetCName(offset)) .. "\"")
  elseif type == "Vector2" then
    local value = frame:GetVector2(offset)

    ImGui.Text("Value:")
    ImGui.BulletText("x = " .. tostring(value.X))
    ImGui.BulletText("y = " .. tostring(value.Y))
  elseif type == "Vector3" then
    local value = frame:GetVector3(offset)

    ImGui.Text("Value:")
    ImGui.BulletText("x = " .. tostring(value.X))
    ImGui.BulletText("y = " .. tostring(value.Y))
    ImGui.BulletText("z = " .. tostring(value.Z))
  elseif type == "Vector4" then
    local value = frame:GetVector4(offset)

    ImGui.Text("Value:")
    ImGui.BulletText("x = " .. tostring(value.X))
    ImGui.BulletText("y = " .. tostring(value.Y))
    ImGui.BulletText("z = " .. tostring(value.Z))
    ImGui.BulletText("w = " .. tostring(value.W))
  end
end

return DataViewerView
