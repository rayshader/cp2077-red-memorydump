local Controller = require_verbose("Controllers/Controller")

local OptionsController = Controller:new()

function OptionsController:new(signal)
  local obj = Controller:new(signal)
  setmetatable(obj, { __index = OptionsController })

  obj.hideProperties = true
  --obj.showHeatMap = false
  --obj.showDuplicates = true
  return obj
end

function OptionsController:SetProperties(value)
  if self.hideProperties == value then
    return
  end
  self.hideProperties = value
  self:Emit("options", "OnPropertiesToggled", value)
end

function OptionsController:SetHeatMap(value)
  if self.showHeatMap == value then
    return
  end
  self.showHeatMap = value
  self:Emit("options", "OnHeatMapToggled", value)
end

function OptionsController:SetDuplicates(value)
  if self.showDuplicates == value then
    return
  end
  self.showDuplicates = value
  self:Emit("options", "OnDuplicatesToggled", value)
end

return OptionsController
