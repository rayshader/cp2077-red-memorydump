return function()
  print("[RedMemoryDump] Implement a custom behavior in RedMemoryDump/AddCustomTarget.lua")
  local target = nil

  --[[
  target = MemoryDump.TrackScriptable(object)
  target = MemoryDump.TrackSerializable(object)
  target = MemoryDump.TrackAddress(name, type, address[, size])
  --]]
  return target
end
