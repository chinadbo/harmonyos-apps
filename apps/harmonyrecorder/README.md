# HarmonyRecorder

HarmonyRecorder is a HarmonyOS screen recording app scaffold targeting API 12+.

## Features

- System-level screen recording with countdown and optional microphone audio
- Recording states: idle, counting, recording, paused
- Floating window controls for picture-in-picture style recording mode
- Canvas-based annotation overlay with pen, arrow, rectangle, and circle tools
- Recording library with sorting, preview, delete, and share entry points
- AVPlayer-based preview workflow
- GIF conversion pipeline with progress reporting

## Project structure

- `AppScope/app.json5`: app metadata
- `build-profile.json5` and `oh-package.json5`: project build metadata
- `entry/src/main/module.json5`: module config and permissions
- `entry/src/main/ets/entryability/EntryAbility.ets`: stage model entry ability
- `entry/src/main/ets/pages`: app pages
- `entry/src/main/ets/components`: reusable ArkUI V1 components
- `entry/src/main/ets/service`: recording, floating window, and GIF services
- `entry/src/main/ets/utils`: permissions, files, and thumbnail helpers
- `privacy_statement.json`: privacy disclosure

## Key implementation notes

- Uses ArkUI V1 decorators only
- Uses `@ohos.*` imports only
- Requests only the permissions required by the spec
- Wraps platform APIs behind services so UI pages stay simple
- Stores generated recordings in the app files directory under `recordings/`

## Build

1. Open the project in DevEco Studio with a HarmonyOS API 12+ SDK.
2. Sync project metadata if the local toolchain requests regeneration.
3. Build and run the `entry` module on a supported HarmonyOS device or emulator.
4. Grant screen capture and media permissions when prompted.

## Verification checklist

- Launch the app to `pages/HomePage`
- Start a recording from `pages/RecordingPage`
- Pause, resume, stop, and enter floating mode
- Open `pages/RecordingListPage` to inspect saved files
- Open `pages/RecordingPreviewPage` for AVPlayer-based preview
- Open `pages/GifConvertPage` to export a GIF and inspect progress
- Change defaults in `pages/SettingsPage`
