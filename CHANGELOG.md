# Changelog

## 0.7.1 — 2026-09-28

- Keep an RMB Detonate press for at most 200 ms when only the conservative avatar-scope check transiently blocks it. Recheck the same C4 and native action state before calling the game; preserve the original Aim behavior.
- Preserve the press time when a recovered request moves behind an active Deploy in the existing one-slot queue. Focus, UI, reload, weapon change, native blockers and timeout cancel the short retry.
- The tester confirmed basic 0.7.0 Deploy/Detonate gameplay. Its local log contains 50 started Detonate actions and 30 rejected Detonate presses; 20 of 26 idle scope rejections reached a ready state within 200 ms. The 0.7.1 retry remains untested in game.

## 0.7.0 — 2026-09-27

- Port the PC mouse/keyboard runtime to Helldivers 2 Steam build 25480438. Left click Deploys C4; right click Detonates. Remove controller input from the current runtime, while retaining older versions as historical files.
- Recheck the C4 native action entry points, module hash, 28 code signatures, component layouts and Fire flag. Read-only live mission checks accepted the equipped C4 in both selected modes.
- Build with Bingus Shared Loader v18. This package's actual Deploy/Detonate results in game remain unverified; the older 0.6.x gameplay record is for build 24826606.

## 0.6.1 — 2026-09-22

- Swap the automatic version's mouse controls: LMB Deploy, RMB Detonate.
- Keep Xbox LT/RT and PlayStation L2/R2 controls unchanged.
- Validate the new mapping offline; gameplay verification remains pending.

## 0.6.0 — 2026-09-20

First public package named **HD2 C4 Quick Actions**, preserving the tested EXP06 runtime.

- Automatic activation while the local C4 is equipped; F6 is no longer required.
- R reload pauses custom input instead of permanently disabling it.
- Focus/cursor/input guards resume after a released baseline and discard paused pending actions.
- Mouse RMB/LMB, Xbox LT/RT and PlayStation L2/R2 mapping retained.
- MIT-licensed source, tests, portable packaging tools, research notes and sanitized traces included.

## Research stages

- EXP05: engine gamepad profiles, analog hysteresis, exact guard-key diagnostics and four-part rotating logs. Xbox basic operation confirmed by the tester; R reload disarm identified.
- EXP04: physical mouse mapping with scoped original Fire suppression/restoration. Basic gameplay confirmed.
- EXP03: native Deploy/Detonate lifecycle, eligibility, action lock and bounded pending. Cross-mode actions confirmed; reload pre-trigger expansion was not pursued.
- EXP02: local weapon, ownership, mode and descriptor observation.
- EXP01: mouse input and API observation.

See [research](research/README.md) for the original requirements and stage reports.
