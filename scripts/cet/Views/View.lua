---@class View
---@field controller Controller
---@field theme Theme
local View = {}

---@param controller Controller
---@param theme Theme
function View:new(controller, theme)
  local obj = {}
  setmetatable(obj, { __index = View })

  obj.controller = controller
  obj.theme = theme
  return obj
end

---@param width number?
function View:Draw(width)
end

return View
