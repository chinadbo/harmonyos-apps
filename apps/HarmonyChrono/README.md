# HarmonyChrono

HarmonyChrono is a HarmonyOS stopwatch app built with ArkTS and V1 decorators.

## Features
- Start, pause, resume, and reset a stopwatch
- Millisecond stopwatch display in `MM:SS.mmm`
- Lap recording with fastest and slowest lap highlighting
- Local RDB persistence for sessions, laps, and settings
- History and session detail pages
- Settings for sound, vibration, theme, and precision
- Workout mode presets and a custom interval plan
- Ongoing stopwatch notification

## Structure
- `entry/src/main/ets/model`: persistence and stopwatch state models
- `entry/src/main/ets/services`: app-level stopwatch service and notifications
- `entry/src/main/ets/components`: reusable ArkUI components
- `entry/src/main/ets/pages`: stopwatch, history, detail, settings, and workout pages
- `entry/src/main/ets/common`: constants, utilities, and shared styling

## Build
Open the app in DevEco Studio or build the module with the HarmonyOS build toolchain available in the repo environment.

## Notes
The stopwatch uses a wall-clock anchored timing model so elapsed time remains correct across pauses, resumes, and process restore.
