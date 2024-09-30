---@class View
---@field private _controller Controller
---
---@field protected theme Theme
local View = {}

---@param controller Controller
---@param theme Theme
function View:new(controller, theme)
  local obj = {}
  setmetatable(obj, { __index = View })

  obj._controller = controller
  obj.theme = theme
  return obj
end

---@param width number?
function View:Draw(width)
  self._controller:Attach(self)
end

---@protected
---@param fn string
---@vararg any
function View:Call(fn, ...)
  self._controller:Queue(fn, ...)
end

return View
