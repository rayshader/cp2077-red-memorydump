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

---@param handles MemorySearchHandle[]
---@return MemoryProperty[]
function MemoryProperty.FromHandles(handles)
  local properties = {}

  for _, handle in ipairs(handles) do
    local name = string.format("unk%X", handle.offset)
    local type = "handle:" .. handle.type

    if handle.offset == 0x8 then
      name = "ref"
      type = "whandle:ISerializable"
    end
    table.insert(properties, {
      handle = nil,
      name = name,
      offset = handle.offset,
      type = type,
      size = 0x10
    })
  end
  return properties
end

return MemoryProperty
