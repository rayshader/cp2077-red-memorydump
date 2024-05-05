return function()
  --[[
  print("[RedMemoryDump] Implement a custom behavior in RedMemoryDump/AddCustomTarget.lua")
  local target = nil

  target = MemoryDump.TrackScriptable(...)
  target = MemoryDump.TrackSerializable(...)
  target = MemoryDump.TrackAddress(...)
  --]]
  local state = Game.GetWeatherSystem():GetWeatherState()
  local target = MemoryDump.TrackSerializable(state)

  return target
end
