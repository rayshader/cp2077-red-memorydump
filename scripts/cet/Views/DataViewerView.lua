local View = require_verbose("Views/View")

---@class DataViewerView : View
---@field controller DataViewerController
local DataViewerView = View:new()

---@param controller DataViewerController
---@param theme Theme
---@overload fun(controller: Controller, theme: Theme): DataViewerView
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

  ---@type number | string
  local address = (self.controller.targetAddress or -1) + (self.controller.offset or -1)

  if address < 0 then
    address = "0x????????????????"
  else
    address = string.format("0x%08X", address)
  end
  ImGui.Text(address)
  ImGui.NextColumn()

  ---@type string | number?
  local offset = self.controller.offset

  if offset == nil then
    offset = "?"
  else
    offset = string.format("0x%X", offset)
  end
  ImGui.Text(offset)
  ImGui.NextColumn()

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
    local value = frame:GetBool(offset)

    ImGui.Text("Value: " .. tostring(value == true))
  elseif type == "Int32" then
    local value = frame:GetInt32(offset)

    ImGui.Text("Value:")
    ImGui.Text("· " .. tostring(value))
    ImGui.Text("· " .. string.format("0x%08X", value))
  elseif type == "Int64" then
    local value = frame:GetInt64(offset)

    ImGui.Text("Value:")
    ImGui.Text("· " .. tostring(value))
    ImGui.Text("· " .. string.format("0x%016X", value))
  elseif type == "Uint32" then
    local value = frame:GetUint32(offset)

    ImGui.Text("Value:")
    ImGui.Text("· " .. tostring(value))
    ImGui.Text("· " .. string.format("0x%08X", value))
  elseif type == "Uint64" then
    local value = frame:GetUint64(offset)

    ImGui.Text("Value:")
    ImGui.Text("· " .. tostring(value))
    ImGui.Text("· " .. string.format("0x%016X", value))
  elseif type == "Float" then
    ImGui.Text("Value: " .. tostring(frame:GetFloat(offset)))
  elseif type == "Double" then
    ImGui.Text("Value: " .. tostring(frame:GetDouble(offset)))
  elseif type == "String" then
    ImGui.Text("Value: \"" .. tostring(frame:GetString(offset)) .. "\"")
  elseif type == "CName" then
    ImGui.Text("Value: n\"" .. NameToString(frame:GetCName(offset)) .. "\"")
  elseif type == "FixedPoint" then
    local value = frame:GetFixedPoint(offset)

    ImGui.Text("Value: " .. tostring(value))
  elseif type == "RectF" then
    local value = frame:GetRectF(offset)

    ImGui.Text("Value:")
    ImGui.Text("· top = " .. tostring(value.Top))
    ImGui.Text("· left = " .. tostring(value.Left))
    ImGui.Text("· right = " .. tostring(value.Right))
    ImGui.Text("· bottom = " .. tostring(value.Bottom))
  elseif type == "Point" then
    local value = frame:GetPoint(offset)

    ImGui.Text("Value:")
    ImGui.Text("· x = " .. tostring(value.x))
    ImGui.Text("· y = " .. tostring(value.y))
  elseif type == "Point3D" then
    local value = frame:GetPoint3D(offset)

    ImGui.Text("Value:")
    ImGui.Text("· x = " .. tostring(value.x))
    ImGui.Text("· y = " .. tostring(value.y))
    ImGui.Text("· z = " .. tostring(value.z))
  elseif type == "Box" then
    local value = frame:GetBox(offset)

    ImGui.Text("Value:")
    ImGui.Text("· min")
    ImGui.Text("  · x = " .. tostring(value.Min.x))
    ImGui.Text("  · y = " .. tostring(value.Min.y))
    ImGui.Text("  · z = " .. tostring(value.Min.z))
    ImGui.Text("  · w = " .. tostring(value.Min.w))
    ImGui.Text("· max")
    ImGui.Text("  · x = " .. tostring(value.Max.x))
    ImGui.Text("  · y = " .. tostring(value.Max.y))
    ImGui.Text("  · z = " .. tostring(value.Max.z))
    ImGui.Text("  · w = " .. tostring(value.Max.w))
  elseif type == "Quad" then
    local value = frame:GetQuad(offset)
    ---@type Vector4[]
    local points = {value.pt1, value.pt2, value.pt3, value.pt4}

    ImGui.Text("Value:")
    for i, point in ipairs(points) do
      ImGui.Text("· pt" + tostring(i + 1))
      ImGui.Text("  · x = " .. tostring(point.x))
      ImGui.Text("  · y = " .. tostring(point.y))
      ImGui.Text("  · z = " .. tostring(point.z))
      ImGui.Text("  · w = " .. tostring(point.w))
    end
  elseif type == "Vector2" then
    local value = frame:GetVector2(offset)

    ImGui.Text("Value:")
    ImGui.Text("· x = " .. tostring(value.X))
    ImGui.Text("· y = " .. tostring(value.Y))
  elseif type == "Vector3" then
    local value = frame:GetVector3(offset)

    ImGui.Text("Value:")
    ImGui.Text("· x = " .. tostring(value.x))
    ImGui.Text("· y = " .. tostring(value.y))
    ImGui.Text("· z = " .. tostring(value.z))
  elseif type == "Vector4" then
    local value = frame:GetVector4(offset)

    ImGui.Text("Value:")
    ImGui.Text("· x = " .. tostring(value.x))
    ImGui.Text("· y = " .. tostring(value.y))
    ImGui.Text("· z = " .. tostring(value.z))
    ImGui.Text("· w = " .. tostring(value.w))
  elseif type == "Matrix" then
    local value = frame:GetMatrix(offset)
    ---@type Vector4[]
    local rows = {value.X, value.Y, value.Z, value.W}
    local labels = {"X", "Y", "Z", "W"}

    ImGui.Text("Value:")
    for i, row in ipairs(rows) do
      ImGui.Text("· " .. labels[i])
      ImGui.Text("  · x = " .. tostring(row.x))
      ImGui.Text("  · y = " .. tostring(row.y))
      ImGui.Text("  · z = " .. tostring(row.z))
      ImGui.Text("  · w = " .. tostring(row.w))
    end
  elseif type == "Transform" then
    local value = frame:GetTransform(offset)
    local o = value.orientation
    local p = value.position

    ImGui.Text("Orientation:")
    ImGui.Text("· i = " .. tostring(o.i))
    ImGui.Text("· j = " .. tostring(o.j))
    ImGui.Text("· k = " .. tostring(o.k))
    ImGui.Text("· r = " .. tostring(o.r))
    ImGui.Spacing()
    ImGui.Text("Position:")
    ImGui.Text("· x = " .. tostring(p.x))
    ImGui.Text("· y = " .. tostring(p.y))
    ImGui.Text("· z = " .. tostring(p.z))
    ImGui.Text("· w = " .. tostring(p.w))
  elseif type == "QsTransform" then
    local value = frame:GetQsTransform(offset)
    local r = value.Rotation
    local s = value.Scale
    local t = value.Translation

    ImGui.Text("Rotation:")
    ImGui.Text("· i = " .. tostring(r.i))
    ImGui.Text("· j = " .. tostring(r.j))
    ImGui.Text("· k = " .. tostring(r.k))
    ImGui.Text("· r = " .. tostring(r.r))
    ImGui.Spacing()
    ImGui.Text("Scale:")
    ImGui.Text("· x = " .. tostring(s.x))
    ImGui.Text("· y = " .. tostring(s.y))
    ImGui.Text("· z = " .. tostring(s.z))
    ImGui.Text("· w = " .. tostring(s.w))
    ImGui.Spacing()
    ImGui.Text("Translation:")
    ImGui.Text("· x = " .. tostring(t.x))
    ImGui.Text("· y = " .. tostring(t.y))
    ImGui.Text("· z = " .. tostring(t.z))
    ImGui.Text("· w = " .. tostring(t.w))
  elseif type == "Quaternion" then
    local value = frame:GetQuaternion(offset)

    ImGui.Text("Value:")
    ImGui.Text("· i = " .. tostring(value.i))
    ImGui.Text("· j = " .. tostring(value.j))
    ImGui.Text("· k = " .. tostring(value.k))
    ImGui.Text("· r = " .. tostring(value.r))
  elseif type == "EulerAngles" then
    local value = frame:GetEulerAngles(offset)

    ImGui.Text("Value:")
    ImGui.Text("· pitch = " .. tostring(value.pitch))
    ImGui.Text("· roll = " .. tostring(value.roll))
    ImGui.Text("· yaw = " .. tostring(value.yaw))
  elseif type == "WorldPosition" then
    local value = frame:GetWorldPosition(offset)

    value = WorldPosition.ToVector4(value)
    ImGui.Text("Value:")
    ImGui.Text("· x = " .. tostring(value.x))
    ImGui.Text("· y = " .. tostring(value.y))
    ImGui.Text("· z = " .. tostring(value.z))
  elseif type == "WorldTransform" then
    local value = frame:GetWorldTransform(offset)
    local o = value.Orientation
    local p = WorldPosition.ToVector4(value.Position)

    ImGui.Text("Orientation:")
    ImGui.Text("· i = " .. tostring(o.i))
    ImGui.Text("· j = " .. tostring(o.j))
    ImGui.Text("· k = " .. tostring(o.k))
    ImGui.Text("· r = " .. tostring(o.r))
    ImGui.Spacing()
    ImGui.Text("Position:")
    ImGui.Text("· x = " .. tostring(p.x))
    ImGui.Text("· y = " .. tostring(p.y))
    ImGui.Text("· z = " .. tostring(p.z))
    ImGui.Text("· w = " .. tostring(p.w))
  elseif type == "Color" then
    local value = frame:GetColor(offset)

    ImGui.Text("Value:")
    ImGui.Text("· r = " .. tostring(value.Red))
    ImGui.Text("· g = " .. tostring(value.Green))
    ImGui.Text("· b = " .. tostring(value.Blue))
    ImGui.Text("· a = " .. tostring(value.Alpha))
  elseif type == "ColorBalance" then
    local value = frame:GetColorBalance(offset)

    ImGui.Text("Value:")
    ImGui.Text("· r = " .. tostring(value.Red))
    ImGui.Text("· g = " .. tostring(value.Green))
    ImGui.Text("· b = " .. tostring(value.Blue))
    ImGui.Text("· l = " .. tostring(value.Luminance))
  elseif type == "HDRColor" then
    local value = frame:GetHDRColor(offset)

    ImGui.Text("Value:")
    ImGui.Text("· r = " .. tostring(value.Red))
    ImGui.Text("· g = " .. tostring(value.Green))
    ImGui.Text("· b = " .. tostring(value.Blue))
    ImGui.Text("· a = " .. tostring(value.Alpha))
  elseif type == "curveData:Float" then
    if self.controller.warning then
      local color = self.theme.colors.error

      ImGui.PushStyleColor(ImGuiCol.Text, color[1], color[2], color[3], color[4])
      ImGui.TextWrapped("Printing this type is currently not safe. Game can crash to desktop. If you know what you're doing:")
      ImGui.PopStyleColor()
      if ImGui.Button("Confirm", -1, 0) then
        self.controller.warning = false
      else
        return
      end
    end
    local value = frame:GetCurveDataFloat(offset)
    local points = value:GetPoints()
    local values = value:GetValues()
    size = value:GetSize()

    ImGui.Text("Size: " .. tostring(size))
    ImGui.Text("Values:")
    for i = 1,size do
      ImGui.Text(string.format("· %.6f = %.6f", points[i], values[i]))
    end
  end
end

return DataViewerView
