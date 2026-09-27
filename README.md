![HD2 C4 Quick Actions — C4 gameplay cover](assets/cover.png)

# HD2 C4 Quick Actions

[繁體中文](README.zh-TW.md)

PC mouse and keyboard controls for C4 in **Helldivers 2**. While holding the C4 detonator, **left click deploys** and **right click detonates**. The controls activate automatically and work independently of the selected C4 firing mode. Other weapons retain their original mouse behavior. Version 0.7.0 has no controller input route.

## Install

1. Close the game. Install [Bingus Shared Loader v18](https://github.com/CowboyBingus/BingusSharedLoader/releases/tag/v18) separately.
2. Import [HD2-C4-Quick-Actions-v0.7.0-PC.zip](dist/HD2-C4-Quick-Actions-v0.7.0-PC.zip) into your mod manager, enable it and the loader, then deploy.
3. Disable earlier C4 Quick Actions packages; keep one version enabled.

The ZIP in `dist/` is the installable mod. A GitHub source-code ZIP is the development repository. To remove the mod, disable it and redeploy in your manager. The package is created locally; building it does not change the game's files.

## Controls and behavior

| PC input | C4 action |
| --- | --- |
| Left mouse button | Deploy |
| Right mouse button | Detonate |

Equip the C4 detonator and release both mouse buttons before the first action. F6 is not required. Holding a button does not repeatedly request an action; simultaneous presses prioritize Detonate. R retains the game's reload timing. Reload, menus, visible UI cursors and focus loss pause custom input. Release both buttons before pressing again. F7 adds an optional log marker.

The mod calls the game's original action lifecycle; it does not directly spawn charges or explosions. Original Aim behavior remains. Its C4-only Fire gate restores normal weapon input when switching weapons or pausing.

## Compatibility and validation

Version 0.7.0 targets Steam game build **`25480438`**. The runtime checks the `game.dll` disk hash and 28 native code signatures before taking control and before action calls. Read-only observation in a live mission confirmed local C4 identity, both firing modes, C4 resource and action admission fields. PC input checks passed offline. **This new package has not yet performed Deploy or Detonate in the game.** Animation, visual effect, multiplayer and edge-case UI/movement behavior still need gameplay verification.

Earlier 0.6.x gameplay results refer to build `24826606` and do not validate 0.7.0. See the [validation record](docs/VALIDATION.md) for the evidence boundary. Historical controller code and packages remain in the repository, but this release does not read controller inputs.

## Build from source

Use Python 3.10+ and LuaJIT 2.1:

```bash
python -B scripts/check_pc.py
python -B scripts/build.py --loader /path/to/BingusSharedLoader-v18
```

The packaging helper is pinned in [dependencies.lock.json](dependencies.lock.json). See [building](docs/BUILDING.md), [architecture](docs/ARCHITECTURE.md) and [research](research/README.md).

Project-authored code and documentation use the [MIT License](LICENSE). External dependencies and game material retain their own terms; see [third-party references](THIRD_PARTY.md). Research, implementation and documentation involved AI assistance; live observations and simulated checks are identified separately.

This repository preserves the earlier Git history of [etxp/HD2-C4-Quick-Actions](https://github.com/etxp/HD2-C4-Quick-Actions). The 0.7.0 PC-only version here is a separate snapshot of that work.
