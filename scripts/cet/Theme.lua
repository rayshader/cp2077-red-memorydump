---@class Theme
---@field colors {hovered: number[], selected: number[], error: number[], search: number[]}
local Theme = {}

function Theme:new()
  local obj = {}
  setmetatable(obj, { __index = Theme })

  obj.colors = {
    hovered = { 0.33725, 0.78823, 1, 1 },
    selected = { 1, 0.65882, 0.16470, 1 },
    error = { 0.95294, 0.12156, 0.12156, 1 },
    success = { 0.12156, 0.95294, 0.12156, 1 },
    search = { 0.19215, 0.89411, 0.15686, 1 },
  }
  return obj
end

return Theme