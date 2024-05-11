local Utils = {}

---@param type string
---@return number
function Utils.GetTypeSize(type)
  if type == "Bool" then
    return 1
  elseif type == "Int32" or type == "Uint32" or type == "Float" then
    return 4
  elseif type == "Int64" or type == "Uint64" or type == "Double" or type == "CName" then
    return 8
  elseif type == "Vector2" then
    return 2 * 4
  elseif type == "Vector3" or type == "EulerAngles" or type == "WorldPosition" then
    return 3 * 4
  elseif type == "Vector4" or type == "Quaternion" then
    return 4 * 4
  elseif type == "WorldTransform" then
    return 32
  else
    return 0
  end
end

---@param offset number
---@param dataOffset number
---@param dataSize number
function Utils.IsInRange(offset, dataOffset, dataSize)
  return dataOffset >= 0 and offset >= dataOffset and offset < dataOffset + dataSize
end

---@param properties MemoryProperty[]
---@param offset number
---@return MemoryProperty | nil
function Utils.FindProperty(properties, offset)
  properties = properties or {}
  for _, property in ipairs(properties) do
    if Utils.IsInRange(offset, property.offset, property.size) then
      return property
    end
  end
  return nil
end

---@param type string
---@return boolean
function Utils.IsTypeUnknown(type)
  if string.find(type, "curveData:") ~= nil then
    return true
  end
  return false
end

return Utils
