# Validation record

## Current 0.7.1 PC short-click fix

Version **0.7.1** targets Steam build **25480438** and accepts only PC mouse/keyboard input: LMB Deploy, RMB Detonate. The gamepad input module is absent from the generated runtime. The prior 0.6.1 and 0.7.0 ZIPs remain as historical outputs.

The current local `game.dll` disk SHA-256 is `2e2c3b7c2500646dadd5f2b4c6e0504dbb7e7896139f64cddc0d1813c718f51e`. All **28** selected native signatures in [pc-layout.json](../evidence/pc-layout.json) matched the loaded game module. Native action entry points and the C4 Fire bit were mapped through old/new code comparison; the new live C4 flags were observed as `0x2148`.

The earlier read-only evaluation of the **ported Lua context and action readers** during a local mission accepted the equipped C4 in both selected modes. In Deploy mode it found the C4 resource, ability template, rounds configuration, chamber token 55 and `action_gate=READY`. In Detonate mode it found the same C4 identity, chamber token 0, `deploy_ammo_ready=false` and `action_gate=READY`. The [sanitized observation](../evidence/pc-live-context.json) contains no pointers, entity IDs or game paths. That check did not execute actions; the later 0.7.0 user test did.

The tester reported that 0.7.0 could Deploy and Detonate in game, but short RMB presses were intermittent. The local 0.7.0 log recorded **50 Detonate native starts**, **30 Detonate rejections** under the conservative avatar-scope veto, and no action faults. Of 26 idle Detonate rejections, 20 reached `READY` on the same C4 within 200 ms. These counts show the input was recognized; they do not prove that native Aim caused the veto. Raw logs remain local and are not published.

`python -B scripts/check_pc.py` runs PC edge tests at 30/60/144 Hz, short RMB retry and cancellation tests, other-weapon routing, controller absence and Lua syntax. Its [machine-readable result](../evidence/pc-offline-tests.json) records source/input hashes. The [package report](../evidence/public-package.json) verifies that the ZIP's Lua bytes match this tested source. **The 0.7.1 retry itself has not yet been tested in game.**

## Local 0.6.1 package

Version **0.6.1** swaps only the automatic runtime's mouse inputs: LMB Deploy and RMB Detonate. Xbox LT/RT and PlayStation L2/R2 remain unchanged. The new mapping is covered by synthetic-memory and mock-native checks. It has not yet been verified in game; the package build does not run the game.

## Earlier 0.6.0 gameplay record

Version **0.6.0**, based on the user-tested runtime **0.6.0-exp06**, game build **24826606**. That package changed its display name and documentation while retaining these exact runtime bytes:

`4134de7cb71ff39a738c13122dc23fe1ec09535397d1e455efb7ab5f687cdb40`

The tester reported that the automatic version appeared to work normally. This confirms basic operation in the tested setup, not every possible device, menu or multiplayer case.

## Latest automatic session

The [sanitized EXP06 trace](../research/traces/exp06-automatic.jsonl) preserves 1,201 event records in order:

| Observation | Result |
| --- | --- |
| Deploy calls / native completions | 31 / 31 |
| Detonate calls / native completions | 52 / 52 |
| Recorded action/probe faults | 0 |
| Permanent feature-disarm events | 0 |
| R fresh press records | 5 |
| Cursor-visible pause transitions | 6 |
| Focus-loss pause transitions | 2 |
| Gameplay-state transitions | 14 |
| Input press records | LMB 79, RMB 32, RT 10, LT 10 |

All 83 called actions in this session used the selected Deploy mode; 52 Detonate actions therefore also have opposite-mode native lifecycle evidence. The earlier experiment established both selected modes; this session alone does not re-test both modes.

Four chamber-blocked, two control/native-state and one pending-coalescing rejections were recorded. These are recorded admission/queue outcomes, not action faults. Counts of presses need not equal calls because native state and the action lock still apply.

Observed native completion is separate from visual throw/explosion confirmation. The tester's broad success report provides the gameplay confirmation for this session; exact backpack consumption, network replication and every pause case were not separately annotated.

## Reload fix and controller baseline

The [EXP05 reload trace](../research/traces/exp05-reload.jsonl) shows a fresh R press and `capture=false`, `reason=menu_key_edge`, at the same tick **6941**. That version treated reload as permanent disarm. The automatic version changes this to a transient pause. The earlier [controller trace](../research/traces/exp05-controller.jsonl) contains Xbox inputs and successful native lifecycles, supported by the tester's Xbox success report.

Sanitization preserves event order and diagnostic/action fields while removing session names, timestamps, paths, entity identities, pointers and memory snapshots. Its field allowlist and hashes are in the [trace manifest](../research/traces/manifest.json). Raw private logs are not bundled; sanitized traces are not byte-identical originals.

## Offline checks

The historical `python -B scripts/check_automatic.py` suite checks automatic activation, empty→supply→reload recovery, held controls, mouse/Xbox/PS profiles, both firing modes at simulated 30/60/144 Hz, pending cancellation, native gates, restoration, callback/log failures, rolling logs and collection for 0.6.1.

These are synthetic-memory/mock-native checks, not game execution. The [machine-readable result](../evidence/automatic-offline-tests.json) includes commands, outputs and input hashes. The [package report](../evidence/public-package.json) checks archive contents and exact source bytes.

## Remaining scope

- Multiplayer host/client and latency scenarios.
- Full sprint/dive/vault/stagger/death interruption matrix.
- Every menu/chat/overlay state, especially those without a visible cursor.
- Builds other than the tested game module.
- Actual 0.7.1 short-click retry and visual result in gameplay.

Historical notes retain the conclusions known at each stage and may say “pending” for a case later tested. This document is the current release status.
