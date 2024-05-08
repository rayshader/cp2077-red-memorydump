# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- improve performance when tracking a big memory dump (~1500 bytes).
- only lookup for properties within boundaries of memory dump.
- only show hovered state when mouse is inside of MEMORY / PROPERTIES views.

------------------------

## [0.1.0] - 2024-05-06
### Added
- RED4ext plugin to track and dump memory.
- CET mod with UI to visualize memory.
- CET api to allow other mods to track targets.

<!-- Table of releases -->
[Unreleased]: https://github.com/rayshader/cp2077-red-memorydump/compare/v0.1.0...HEAD
[0.2.0]: https://github.com/rayshader/cp2077-red-memorydump/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/rayshader/cp2077-red-memorydump/releases/tag/v0.1.0
