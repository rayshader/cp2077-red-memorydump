---@class Utils
---@field types table<string, number>
local Utils = {}

Utils.typeLabels = {
"Bool",

"Int32",
"Uint32",
"Int64",
"Uint64",
"Float",
"Double",

"String",
"CName",

"FixedPoint",
"RectF",
"Point",
"Point3D",
"Box",
"Quad",

"Vector2",
"Vector3",
"Vector4",
"Matrix",
"Transform",
"QsTransform",
"Quaternion",
"EulerAngles",
"WorldPosition",
"WorldTransform",

"Color",
"ColorBalance",
"HDRColor",

"curveData:Float",
}

Utils.types = {
  Bool = 1,

  Int32 = 4,
  Uint32 = 4,
  Int64 = 8,
  Uint64 = 8,

  Float = 4,
  Double = 8,

  String = 0,
  CName = 8,

  FixedPoint = 4,
  RectF = 16,
  Point = 8,
  Point3D = 12,
  Box = 32,
  Quad = 64,

  Vector2 = 8,
  Vector3 = 12,
  Vector4 = 16,
  Matrix = 64,
  Transform = 32,
  QsTransform = 48,
  Quaternion = 16,
  EulerAngles = 12,
  WorldPosition = 12,
  WorldTransform = 32,

  Color = 4,
  ColorBalance = 16,
  HDRColor = 16,

  --curveData:Float = 16,
}

Utils.types["curveData:Float"] = 16

---@param type string
---@return number
function Utils.GetTypeSize(type)
  return Utils.types[type] or 0
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

---@param data any
---@return any
function Utils.clone(data)
  if type(data) ~= "table" then
    return data
  end
  local clone = setmetatable({}, getmetatable(data))

  for key, value in pairs(data) do
    clone[key] = Utils.clone(value)
  end
  return clone
end

return Utils
