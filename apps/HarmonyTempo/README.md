# HarmonyTempo

HarmonyTempo is a HarmonyOS metronome app built with ArkTS V1 decorators and `@ohos.*` imports only.

## Features

- BPM control from 40 to 280
- Time signatures: 2/4, 3/4, 4/4, 5/4, 6/8
- Canvas pulse beat indicator
- Tap tempo
- Three click sounds
- Practice timer
- Dark theme UI for music practice
- Local preferences persistence

## Project structure

- `AppScope/app.json5`
- `build-profile.json5`
- `oh-package.json5`
- `privacy_statement.json`
- `entry/src/main/module.json5`
- `entry/src/main/ets/entryability/EntryAbility.ets`
- `entry/src/main/ets/pages/*`
- `entry/src/main/ets/components/*`
- `entry/src/main/ets/services/*`

## Notes

- Uses `NavPathStack` for navigation.
- Uses `@ohos.multimedia.soundPool` for low-latency click playback.
- Uses `@ohos.data.preferences` for settings persistence.
- No storage or microphone permissions are requested.
