--[[
README
======

Quickly setup an object to track its memory when clicking on button
"Add custom target". This is a QoL feature to prevent repeating commands in
CET's console for example.

AddCustomTarget must return a target using one of the three functions as shown
below. Other functions replicate CET events if you need them.

Argument 'context' is a table {} you can use to store custom data. It is the
same instance used in all functions.
--]]
return {
  -- registerForEvent('onHook')
  OnHook = function(context)
  end,
  -- registerForEvent('onInit')
  OnInit = function(context)
  end,
  -- registerForEvent('onShutdown')
  OnShutdown = function(context)
  end,
  -- Callback of button "Add custom target"
  AddCustomTarget = function(context)
    print("[RedMemoryDump] Implement a custom behavior in RedMemoryDump/AddCustomTarget.lua")
    local target = nil

    --[[
    target = MemoryDump.TrackScriptable(object)
    target = MemoryDump.TrackSerializable(object)
    target = MemoryDump.TrackAddress(name, type, address[, size])
    --]]
    return target
  end
}
