---@class MemoryProperty
---@field handle any
---@field name string
---@field offset number
---@field type string
---@field size number
local MemoryProperty = {}

---@param rttiProperties any[]
---@return MemoryProperty[]
function MemoryProperty.ToTable(rttiProperties)
  local properties = {}

  for _, property in ipairs(rttiProperties) do
    table.insert(properties, {
      handle = property,
      name = property:GetName(),
      offset = property:GetOffset(),
      type = NameToString(property:GetTypeName()),
      size = property:GetTypeSize()
    })
  end
  return properties
end

return MemoryProperty
