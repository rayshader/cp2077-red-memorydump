local OptionsController = {}

function OptionsController:new(signal)
  local obj = {}
  setmetatable(obj, { __index = OptionsController })

  obj.signal = signal
  obj.hideProperties = true
  --obj.showHeatMap = false
  obj.showDuplicates = true
  return obj
end

function OptionsController:SetProperties(value)
  if self.hideProperties == value then
    return
  end
  self.hideProperties = value
  self.signal:Emit("options", "OnPropertiesToggled", value)
end

function OptionsController:SetHeatMap(value)
  if self.showHeatMap == value then
    return
  end
  self.showHeatMap = value
  self.signal:Emit("options", "OnHeatMapToggled", value)
end

function OptionsController:SetDuplicates(value)
  if self.showDuplicates == value then
    return
  end
  self.showDuplicates = value
  self.signal:Emit("options", "OnDuplicatesToggled", value)
end

return OptionsController
