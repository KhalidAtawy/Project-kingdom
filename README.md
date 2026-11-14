# PROJECT KINGDOM

An original portrait mobile 3D Army Runner / Kingdom Progression prototype built with Godot 4.x.

## Current prototype
- Portrait-oriented Godot 4 project using the GL Compatibility renderer.
- Three-lane runner movement with touch/mouse swipe and keyboard fallback.
- Placeholder 3D environment, army formation, HUD, and finish state.
- Add-soldier and army-multiplier gates.
- Gate activation is checked against the runner's lane and world position (rather than relying on a missing physics body).

## Project structure
- `project.godot` — project configuration.
- `scenes/Main.tscn` — main scene.
- `scripts/main.gd` — current greybox gameplay prototype.
- `docs/GAMEPLAY_MVP.md` — MVP gameplay scope.
- `.github/workflows/godot-validation.yml` — automated headless import/startup validation.

## Run locally
1. Install Godot 4.3 or a compatible Godot 4.x standard build (not .NET).
2. Clone this repository.
3. Import `project.godot` in Godot and press Play.

## Status and limitations
This is an early greybox prototype, not a finished game. The gate-detection issue has been corrected in code, but the project has not yet been runtime-validated in this environment. The automated GitHub Actions validation workflow has been added; check the Actions tab for its first run.

Not implemented yet: enemy waves, combat, boss encounters, kingdom building/upgrades, production art/audio, save progression, store integration, and release packaging.

## Target builds
- Android: APK/AAB after Android export templates and SDK/keystore configuration.
- iPhone: Safari-compatible Web export; native iOS/TestFlight requires macOS/Xcode and Apple signing.
