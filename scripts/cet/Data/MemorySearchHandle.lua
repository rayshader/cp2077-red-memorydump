---@class MemorySearchHandle
---@field type string
---@field offset number
local MemorySearchHandle = {}

---@param handles any[]
---@return MemorySearchHandle[]
function MemorySearchHandle.ToTable(handles)
  local results = {}

  for _, handle in ipairs(handles) do
    table.insert(results, {
      type = handle:GetType(),
      offset = handle:GetOffset(),
    })
  end
  return results
end

return MemorySearchHandle
