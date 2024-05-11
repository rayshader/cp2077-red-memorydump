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

  ---@type string | number | nil
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
  elseif type == "Vector2" then
    local value = frame:GetVector2(offset)

    ImGui.Text("Value:")
    ImGui.Text("· x = " .. tostring(value.X))
    ImGui.Text("· y = " .. tostring(value.Y))
  elseif type == "Vector3" then
    local value = frame:GetVector3(offset)

    ImGui.Text("Value:")
    ImGui.Text("· x = " .. tostring(value.X))
    ImGui.Text("· y = " .. tostring(value.Y))
    ImGui.Text("· z = " .. tostring(value.Z))
  elseif type == "Vector4" then
    local value = frame:GetVector4(offset)

    ImGui.Text("Value:")
    ImGui.Text("· x = " .. tostring(value.X))
    ImGui.Text("· y = " .. tostring(value.Y))
    ImGui.Text("· z = " .. tostring(value.Z))
    ImGui.Text("· w = " .. tostring(value.W))
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
    ImGui.Text("· pitch = " .. tostring(value.Pitch))
    ImGui.Text("· roll = " .. tostring(value.Roll))
    ImGui.Text("· yaw = " .. tostring(value.Yaw))
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

    ImGui.Text("Value:")
    ImGui.Text("· orientation = {i: " ..
      tostring(o.i) .. ", j: " .. tostring(o.j) .. ", k: " .. tostring(o.k) .. ", r: " .. tostring(o.r) .. "}")
    ImGui.Text("· position = {x: " .. tostring(p.x) .. ", y: " .. tostring(p.y) .. ", z: " .. tostring(p.z) .. "}")
  end
end

return DataViewerView
