# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog], and this project adheres to 
[Semantic Versioning].

## [Unreleased]
### Added
- support for RedSocket to communicate with a debugger.
~~- automatically watch discovered handles to try and deduce the kind of 
  reference (strong or weak).~~

------------------------

## [0.7.0] - 2025-01-23
### Fixed
- ignore scripted properties in `PROPERTIES` section. Only bind native
  properties to hide them in memory region of target.

### Changed
- support patch 2.21

### Added
- button to search for handles in a target. It will look for all ISerializable
  currently alive in game engine. When a handle is found in memory region of a
  target, it is added in `PROPERTIES` section. WeakHandle/Handle can't be
  deduced. It still requires a manual check along with a more accurate type
  regarding inheritance.
- checkbox to show/hide heat map in `OPTIONS` section.
- compute/draw heat map based on frames of a target.
- button to delete all frames of a target.

------------------------

## [0.6.0] - 2025-01-14
### Changed
- support patch 2.2

------------------------

## [0.5.1] - 2024-10-02
### Removed
- hovering a property will no longer scroll to its offset in `MEMORY` view.

### Changed
- improve performance with well implemented `onUpdate` / `onDraw` callbacks.
- cap GUI rendering to 30 fps.

------------------------

## [0.5.0] - 2024-09-18
### Removed
- buttons to navigate to previous / next frame, in favor of a player.

### Added
- player to animate through frames every 200 ms.
- record/dump frames at a custom rate (every 66 ms to 1000 ms), with start/stop
  button or hot key.

------------------------

## [0.4.1] - 2024-09-16
### Fixed
- order of data types in `DATA VIEWER`.

------------------------

## [0.4.0] - 2024-09-16
### Fixed
- disable target when `ISerializable` is disposed.
- printing of data types `Vector3`, `Vector4` and `EulerAngles`.

### Changed
- remove `TrackScriptable` in favor of only `TrackSerializable`.
- improve UX and responsiveness.

### Added
- support to print data types `FixedPoint`, `RectF`, `Point`, `Point3D`, `Box`,
  `Quad`, `Matrix`, `Transform`, `QsTransform`, `Color`, `ColorBalance`,
  `HDRColor`.
- track selected `inkWidget` from `Ink Inspector` with [RedHotTools].
- track world objects from `World Inspector` with [RedHotTools].
- support of [RedHotTools] is optional.

------------------------

## [0.3.0] - 2024-09-14
### Fixed
- navigation between frames.
- view of data type WorldTransform.

### Deprecated
- deprecate name of function `AddCustomTarget` in favor of `AddTarget`.

### Changed
- support patch 2.13
- improve performance to show bytes of frames in `MEMORY`.

### Added
- callback in API to dynamically capture a frame using `context.Capture()`.
- button to delete selected frame.
- support to print data type `curveData:Float`.

------------------------

## [0.2.0] - 2024-05-08
### Fixed
- improve performance when tracking a big memory dump (~1500 bytes).
- only lookup for properties within boundaries of memory dump.
- only show hovered state when mouse is inside of MEMORY / PROPERTIES views.
- offset selection in DATA VIEWER.

### Added
- support to print data types `Quaternion`, `EulerAngles`, `WorldPosition` and
  `WorldTransform`.
- scroll to property's offset in MEMORY view when hovering it in PROPERTIES
  view. No scroll when a property is selected.

------------------------

## [0.1.0] - 2024-05-06
### Added
- RED4ext plugin to track and dump memory.
- CET mod with UI to visualize memory.
- CET api to allow other mods to track targets.

<!-- Table of links -->
[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
[RedHotTools]: https://github.com/psiberx/cp2077-red-hot-tools

<!-- Table of releases -->
[Unreleased]: https://github.com/rayshader/cp2077-red-memorydump/compare/v0.7.0...HEAD
[0.7.0]: https://github.com/rayshader/cp2077-red-memorydump/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/rayshader/cp2077-red-memorydump/compare/v0.5.1...v0.6.0
[0.5.1]: https://github.com/rayshader/cp2077-red-memorydump/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/rayshader/cp2077-red-memorydump/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.com/rayshader/cp2077-red-memorydump/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/rayshader/cp2077-red-memorydump/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/rayshader/cp2077-red-memorydump/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/rayshader/cp2077-red-memorydump/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/rayshader/cp2077-red-memorydump/releases/tag/v0.1.0
