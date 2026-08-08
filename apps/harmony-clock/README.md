# HarmonyClock

HarmonyClock is a HarmonyOS Stage-model clock application built with ArkTS and V1 decorators. It provides a unified home dashboard, world clocks, alarms, a stopwatch, a timer, and lightweight local settings.

## Features

- Local time dashboard with next-alarm summary
- World clock list with fixed timezone offsets
- Alarm list with enable, disable, add, and delete actions
- Stopwatch with start, pause, and reset
- Countdown timer with presets
- Settings for 24-hour time, vibration toggle, and default timer length

## Project structure

- `AppScope/app.json5` — app bundle metadata
- `entry/src/main/module.json5` — entry module definition
- `entry/src/main/ets/entryability/EntryAbility.ets` — Stage UIAbility bootstrap
- `entry/src/main/ets/pages/*.ets` — ArkUI V1 pages and reusable views
- `entry/src/main/ets/models/*.ets` — app data models
- `entry/src/main/ets/utils/*.ets` — formatting, storage, and notification helpers
- `entry/src/main/ets/services/AlarmService.ets` — alarm state orchestration
- `entry/src/main/resources/base/profile/main_pages.json` — page registration

## Architecture

The application uses a single Stage ability that loads `pages/HomePage`. `HomePage` acts as the shell for the app and switches between the clock sections. Utility classes keep formatting and in-memory storage logic isolated from the UI, while `AlarmService` manages alarm mutations and scheduling state.

## Build

1. Open the project in DevEco Studio.
2. Sync the HarmonyOS module configuration.
3. Build and run the `entry` module on a HarmonyOS device or simulator.

## Notes

- Only `@ohos.*` system imports are used.
- All UI files use the ArkUI V1 decorator model.
- The sample storage layer is self-contained and keeps the project compilable without extra setup.
