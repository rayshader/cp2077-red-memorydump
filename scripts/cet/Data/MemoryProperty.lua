local MemoryProperty = {}

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
