---@class Theme
---@field colors {hovered: number[], selected: number[], error: number[]}
local Theme = {}

function Theme:new()
  local obj = {}
  setmetatable(obj, { __index = Theme })

  obj.colors = {
    hovered = { 0.33725, 0.78823, 1, 1 },
    selected = { 1, 0.65882, 0.16470, 1 },
    error = { 0.95294, 0.12156, 0.12156, 1 }
  }
  return obj
end

return Theme
