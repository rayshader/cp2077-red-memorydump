# Red Memory Dump
![Cyberpunk 2077](https://img.shields.io/badge/Cyberpunk%202077-v2.21-blue)
![GitHub License](https://img.shields.io/github/license/rayshader/cp2077-red-memorydump)
[![Donate](https://img.shields.io/badge/donate-buy%20me%20a%20coffee-yellow)](https://www.buymeacoffee.com/lpfreelance)

This tool allows to dump memory to help in analyzing unknown data types. It 
provides an interface with CET.

# Getting started

## Compatibility
- Cyberpunk 2077 v2.21
- [RED4ext] v1.27.0+
- [Redscript] 0.5.27+
- [Cyber Engine Tweaks] 1.35.0+
- [Red Hot Tools] 1.2.0+

## Installation
1. Install requirements:
- [RED4ext] v1.27.0+
- [Cyber Engine Tweaks] 1.35.0+
- [Red Hot Tools] 1.2.0+
- [RedSocket] 0.2.0+

2. Extract the [latest archive] into the Cyberpunk 2077 directory.

## Demo

![screenshot of tool](https://github.com/rayshader/cp2077-red-memorydump/blob/master/demo.png)

## Features
- track an `ISerializable` or a raw address as a target.
- dump memory of target with the `Capture` button (aka a frame).
- navigate between frames.
- view memory of a frame as bytes in hexadecimal form.
- hide known bytes in view memory, when already bound by RTTI properties.
- select an offset in memory and a data type to check the content (support 
  common types of RED4engine).
- list known RTTI properties, hover/select a property to scroll to it in view 
  memory.
- player to navigate through frames every 200 ms.
- record frames at custom rate, with start/stop button or hot key.
- compute/show heat map to quickly find changing values among captured frames.
- search for handles: look for all `ISerializable` currently alive in game 
  engine. Detect their usage in memory region of current target. It helps to 
  quickly reverse-engineer a class. However, `WeakHandle`/`Handle` cannot be 
  deduced automatically for now. Type might not be accurate enough too. You'll 
  need to manually check them.

## Setup

You'll need to configure CET to use a monospace font. You can import one of 
your choice or pick from existing fonts. For example with 
`NotoSansMono-Regular.ttf`.

In `bin/x64/plugins/cyber_engine_tweaks/`, change `config.json` with:
```json5
{
  // ...
  "fonts": {
    // ...
    "path": "C:/Program Files (x86)/Steam/steamapps/common/Cyberpunk 2077/bin/x64/plugins/cyber_engine_tweaks/fonts/NotoSansMono-Regular.ttf"
    // ...
  }
  // ...
}
```

> [!NOTE]  
> `fonts.path` must be an absolute path to be loaded by CET.

## Usage

This tool introduce `MemoryDump` with two core functions:
```swift
TrackSerializable(object: ref<ISerializable>) -> ref<MemoryTarget>;
TrackAddress(name: String, type: CName, address: Uint64, opt size: Uint32) -> ref<MemoryTarget>;
```

It will return a `MemoryTarget` which allows to dump memory in a "frame".

> [!NOTE]  
> Internally, only a weak reference is hold. When reference is disposed, a
> message will tell. You won't be able to dump new frames.

This tool requires a `MemoryTarget` to print it in CET's overlay. You have two 
possibilities to provide a target:

### CET's console

You can use CET's console to write commands and manually add a target. You 
will need to import the tool's API using:
```lua
RedMemoryDump = GetMod("RedMemoryDump")
```
You can then use `MemoryDump` to track and add a target:
```lua
player = Game.GetPlayer()
target = MemoryDump.TrackSerializable(player)
RedMemoryDump.AddTarget(target)
-- It should be visible in section TARGETS
```

### AddCustomTarget

You can define your custom behavior in [RedMemoryDump/AddCustomTarget.lua] 
where the plugin is installed. You can react to common CET events and return 
a target you want to track.

You must define `AddTarget` which will be triggered when you click on the 
button `Add target` in CET overlay, for example:
```lua
-- See file itself for more.

-- ...
AddTarget = function(context)
  local player = Game.GetPlayer()

  return MemoryDump.TrackSerializable(player)
end
-- ...
```

> [!TIP]  
> This is the recommended solution, DRY.

# Development
Contributions are welcome, feel free to fill an issue or a PR.

## Usage
1. Install requirements:
  - CMake v3.27+
  - Visual Studio Community 2022+
  - [red-cli] v0.4.0+
2. Configure project with:
```shell
cmake -G "Visual Studio 17 2022" -A x64 -S . -B build
```

3. Build in debug mode:
```shell
cmake --build build --target RedMemoryDump --config Debug
```

## Tests
1. Install in your game directory:

```shell
red-cli install
```
 
2. Run game.
3. Open CET, you should see a "RedMemoryDump" window.

## Release
1. Build in release mode:

```shell
cmake --build build --target RedMemoryDump --config Release
```

2. Bundle release:

```shell
red-cli pack
```

<!-- Table of links -->
[RED4ext]: https://github.com/WopsS/RED4ext
[Redscript]: https://github.com/jac3km4/redscript
[Cyber Engine Tweaks]: https://github.com/maximegmd/CyberEngineTweaks
[Red Hot Tools]: https://github.com/psiberx/cp2077-red-hot-tools
[RedSocket]: https://github.com/rayshader/cp2077-red-socket/releases/latest
[latest archive]: https://github.com/rayshader/cp2077-red-memorydump/releases/latest
[RedMemoryDump/AddCustomTarget.lua]: https://github.com/rayshader/cp2077-red-memorydump/blob/master/scripts/cet/AddCustomTarget.lua
[red-cli]: https://github.com/rayshader/cp2077-red-cli/releases/latest