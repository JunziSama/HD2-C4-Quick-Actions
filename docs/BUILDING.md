# Building and validating

Use Python **3.10+** and **LuaJIT 2.1**. The Python build/test tools use the standard library. The PC input tests and historical Lua suites simulate input or game memory; they do not start the game. The assembly and test commands operate relative to this checkout.

## Validate the source

From the repository root:

```bash
python -B scripts/check_pc.py
```

This assembles the current PC-only runtime, checks its input routing and Lua syntax, and records source/input hashes in `evidence/pc-offline-tests.json`. Run `python -B scripts/check_automatic.py` separately to reproduce the historical 0.6.1 mouse/gamepad suite. No loader checkout or game installation is needed for these tests.

The `evidence/*-layout.json` inputs contain build-specific module hashes and native signature bytes required by each version. `pc-layout.json` targets build 25480438; `mouse-layout.json` retains build 24826606 for earlier versions. Rebuilding the Lua source does not require the original game's binary.

## Obtain the packaging helper

The helper is an external dependency. Obtain the pinned commit from its upstream repository:

```bash
git clone https://github.com/CowboyBingus/BingusSharedLoader.git vendor/BingusSharedLoader
git -C vendor/BingusSharedLoader checkout 3d7e3a120828178573ef1ee0a5c7eeae4a951865
python -B scripts/build.py --loader vendor/BingusSharedLoader
```

An existing checkout at any location can be passed with `--loader`. The script checks both helper-file hashes in `dependencies.lock.json` before execution. `vendor/` is ignored by Git and is not part of this source distribution.

The result is `dist/HD2-C4-Quick-Actions-v0.7.0-PC.zip`, plus its SHA-256 checksum and `evidence/public-package.json`. The package contains one Lua addon, manifest, installation text and MIT license; the loader runtime is separate. The archive parser independently checks that its embedded Lua bytes exactly match the tested source. No files are installed into the game.

## Source layout

- `src/c4_pc_auto.lua`: generated current PC-only runtime; `src/c4_dual_input_auto.lua` remains the historical 0.6.1 runtime.
- `src/*_reader.lua`, `action_backend.lua`, `action_controller.lua`: context, eligibility and original action calls.
- `src/weapon_fire_gate.lua`, `fire_gate_windows.lua`: scoped native Fire ownership and restoration.
- `src/pc_tick.lua`, `mouse_router.lua`, `input_guard.lua`, `gameplay_guard.lua`: current PC input and pause/resume. `gamepad_input.lua` and `automatic_tick.lua` remain for history only.
- `scripts/assemble_pc.py`: current PC assembly and build 25480438 adaptation. Earlier staged assemblers remain for historical payloads and regressions.
- `tests/`: synthetic fixtures and runnable tests.
- `research/`: historical notes, earlier research scripts and sanitized runtime traces. See its README for external-input requirements.

Edit component modules and assemblers, then regenerate; changes to a generated Lua file alone are overwritten. If releasing changed runtime behavior, update the version and reviewed source hash in `project.json`, rerun the tests, then rebuild. A changed native/game layout also needs new review and gameplay testing.

## Collect local runtime evidence

```bash
python -B scripts/collect_actions.py --phase exp06 --log-dir /path/to/CowboyBingus/Helldivers2/Logs
```

Or provide `--source /path/to/C4DualInput_session_part1.log`. The collector reconstructs retained ring segments, writes to the ignored `local-evidence/` directory and keeps test-session boundaries. These local logs may contain machine paths and runtime identifiers; the public research traces use a separate, documented field allowlist.
