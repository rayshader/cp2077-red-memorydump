function require_verbose(path)
    local import, err = require(path)

    if err then
        error(err)
    end
    return import
end

local RedMemoryDump = require_verbose("RedMemoryDump")

local mod = RedMemoryDump:new()

registerHotkey('record', 'Start/stop recording frames', function() mod:TriggerHotkey("RecordToggled") end)

registerForEvent('onHook', function() mod:Hook() end)
registerForEvent('onInit', function() mod:Start() end)

registerForEvent('onUpdate', function(delta) mod:Update(delta) end)

registerForEvent('onOverlayOpen', function() mod.gui:Show() end)
registerForEvent('onOverlayClose', function() mod.gui:Hide() end)
registerForEvent('onDraw', function() mod.gui:Draw() end)

registerForEvent('onShutdown', function() mod:Stop() end)

return mod:GetApi()
