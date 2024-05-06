# Red Memory Dump
![Cyberpunk 2077](https://img.shields.io/badge/Cyberpunk%202077-v2.12a-blue)
![GitHub License](https://img.shields.io/github/license/rayshader/cp2077-red-memorydump)
[![Donate](https://img.shields.io/badge/donate-buy%20me%20a%20coffee-yellow)](https://www.buymeacoffee.com/lpfreelance)

This tool allows to dump memory to help in analyzing unknown data types. It 
provides an interface with CET.

# Getting started

## Compatibility
- Cyberpunk 2077 v2.12a
- [RED4ext] v1.24.3+
- [Redscript] 0.5.19+
- [Cyber Engine Tweaks] 1.32.2+

## Installation
1. Install requirements:
  - [RED4ext] v1.24.3+
  - [Redscript] 0.5.19+
  - [Cyber Engine Tweaks] 1.32.2+

2. Extract the [latest archive] into the Cyberpunk 2077 directory.

## Demo

![screenshot of tool](https://github.com/rayshader/cp2077-red-memorydump/blob/master/demo.png)

## Usage

This tool introduce `MemoryDump` with three core functions:
```swift
TrackScriptable(object: ref<IScriptable>) -> ref<MemoryTarget>;
TrackSerializable(object: ref<ISerializable>) -> ref<MemoryTarget>;
TrackAddress(name: String, type: CName, address: Uint64, opt size: Uint32) -> ref<MemoryTarget>;
```

It will return a `MemoryTarget` which allows to dump memory in a "frame".

> [!IMPORTANT]  
> It only keeps the internal pointer of the object. If reference to the 
> object is lost, it will result in unexpected behaviors.

This tool requires a `MemoryTarget` to print it in CET's overlay. You have two 
possibilities to provide a target:

### CET's console

You can use CET's console to write commands and manually add a target. You 
will need to import the tool's API using:
```lua
RedMemoryModApi = GetMod("RedMemoryMod").api
```
You can then use `MemoryDump` to track and add a target:
```lua
player = Game.GetPlayer()
target = MemoryDump.TrackScriptable(player)
RedMemoryModApi.AddTarget(target)
-- It should be visible in section TARGETS
```

### AddCustomTarget

You can define your custom behavior in [RedMemoryDump/AddCustomTarget.lua] 
where the plugin is installed. You can react to common CET events and return 
a target you want to track.

You must define `AddCustomTarget` which will be triggered when you click on 
the button `Add custom target` in CET overlay, for example:
```lua
-- See file itself for more.

-- ...
AddCustomTarget = function(context)
  local player = Game.GetPlayer()

  return MemoryDump.TrackScriptable(player)
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
  - Node JS v20.11+
    - run `npm install --save-dev archiver`
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
node install.mjs
```
 
2. Run game.
3. Open CET, show Game Log popup.
4. Output should show tests result.

## Release
1. Build in release mode:

```shell
cmake --build build --target RedMemoryDump --config Release
```

2. Bundle release:

```shell
node bundle.mjs
```

<!-- Table of links -->
[RED4ext]: https://github.com/WopsS/RED4ext
[Redscript]: https://github.com/jac3km4/redscript
[Cyber Engine Tweaks]: https://github.com/maximegmd/CyberEngineTweaks
[latest archive]: https://github.com/rayshader/cp2077-red-memorydump/releases/latest
[RedMemoryDump/AddCustomTarget.lua]: https://github.com/rayshader/cp2077-red-memorydump/blob/master/scripts/cet/AddCustomTarget.lua