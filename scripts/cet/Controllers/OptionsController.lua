local Controller = require_verbose("Controllers/Controller")

---@class OptionsController : Controller
---@field hideProperties boolean
---@field showHeatMap boolean
---@field showDuplicates boolean
local OptionsController = Controller:new()

---@param signal Signal
function OptionsController:new(signal)
  ---@type OptionsController
  local obj = Controller:new("options", signal)
  setmetatable(obj, { __index = OptionsController })

  obj.hideProperties = true
  --obj.showHeatMap = false
  --obj.showDuplicates = true
  return obj
end

---@param value boolean
function OptionsController:SetProperties(value)
  if self.hideProperties == value then
    return
  end
  self.hideProperties = value
  self:Emit("PropertiesToggled", value)
end

---@param value boolean
function OptionsController:SetHeatMap(value)
  if self.showHeatMap == value then
    return
  end
  self.showHeatMap = value
  self:Emit("HeatMapToggled", value)
end

---@param value boolean
function OptionsController:SetDuplicates(value)
  if self.showDuplicates == value then
    return
  end
  self.showDuplicates = value
  self:Emit("DuplicatesToggled", value)
end

return OptionsController
