-- RedHotTools API types --
---@class RedHotTools
RedHotTools = {
  -- Ink Inspector --

  ---@return inkWidget?
  GetSelectedWidget = function() return nil end,

  -- World Inspector --
  
  ---@return ISerializable?
  GetWorldInspectorTarget = function() return nil end,

  ---@return ISerializable[]
  GetWorldInspectorTargets = function() return {} end,

  ---@return ISerializable[]
  GetWorldScannerResults = function() return {} end,

  ---@return ISerializable[]
  GetWorldScannerFilteredResults = function() return {} end,

  ---@return ISerializable?
  GetLookupResult = function() return nil end,

  ---@return ISerializable[]
  GetLookAtObjects = function() return {} end
}

-- RedMemoryDump types --

---@class MemoryDump
MemoryDump = {
  ---@param target any
  TrackSerializable = function(target) end,

  ---@param name string
  ---@param type string
  ---@param address number
  ---@param size number?
  TrackAddress = function(name, type, address, size) end,
}

---@class MemoryTarget
MemoryTarget = {
  ---@param self MemoryTarget
  ---@return string
  GetName = function(self) return "" end,

  ---@param self MemoryTarget
  ---@return string
  GetType = function(self) return "" end,

  ---@param self MemoryTarget
  ---@return number
  GetSize = function(self) return 0 end,

  ---@param self MemoryTarget
  ---@param size number
  SetSize = function(self, size) end,

  ---@param self MemoryTarget
  ---@return boolean
  IsSizeLocked = function(self) return false end,

  ---@param self MemoryTarget
  ---@return number
  GetAddress = function(self) return 0 end,

  ---@param self MemoryTarget
  ---@return MemoryProperty[]
  GetProperties = function(self) return {} end,

  ---@param self MemoryTarget
  ---@return MemoryFrame[]
  GetFrames = function(self) return {} end,

  ---@param self MemoryTarget
  ---@return MemoryFrame?
  GetLastFrame = function(self) return nil end,

  ---@param self MemoryTarget
  ---@return MemoryFrame?
  Capture = function(self) return nil end,

  ---@param self MemoryTarget
  ---@param index number
  RemoveFrame = function(self, index) end,
}

---@class MemoryFrame
MemoryFrame = {
  ---@param self MemoryFrame
  ---@return number
  GetSize = function(self) return 0 end,

  ---@param self MemoryFrame
  ---@param offset number
  ---@return number
  GetFloat = function(self, offset) return 0 end,

  ---@param self MemoryFrame
  ---@param offset number
  ---@return number
  GetUint64 = function(self, offset) return 0 end,

  ---@return string[]
  GetBufferView = function(self) return {} end
}
