# HarmonyPalette

HarmonyPalette is a HarmonyOS ArkTS color palette design tool. It provides an HSV color wheel, image-based color extraction, palette scheme generation, local favorites storage, and clipboard copy support.

## Features

- Interactive color selection with an HSV canvas wheel
- Image palette extraction with `PhotoViewPicker`
- Palette generation for complementary, analogous, triadic, split-complementary, and monochrome schemes
- Favorite color persistence with RDB
- Detailed color inspection with HEX, RGB, RGBA, and HSV values
- Clipboard copy for design handoff

## Project structure

- `AppScope/app.json5` — app metadata
- `entry/src/main/module.json5` — entry module definition
- `entry/src/main/ets/pages/Index.ets` — main tab shell with `NavPathStack`
- `entry/src/main/ets/pages/*.ets` — feature pages
- `entry/src/main/ets/components/*.ets` — reusable UI widgets
- `entry/src/main/ets/model/*.ets` — shared data models
- `entry/src/main/ets/utils/*.ets` — color conversion and image extraction
- `entry/src/main/ets/database/DatabaseHelper.ets` — local favorites database
- `entry/src/main/ets/services/ShareService.ets` — clipboard integration

## Architecture

The app uses the HarmonyOS ArkTS V1 decorator system only. `Index.ets` owns the main navigation stack and shared app state. Color data flows through `ColorModel`, while `ColorConverter` centralizes conversion and palette generation. `ColorExtractor` uses `PixelMap.readPixels()` to sample image colors. `DatabaseHelper` wraps local RDB access for favorites, and `ShareService` handles clipboard copy.

## Build

1. Open the project in DevEco Studio.
2. Make sure the HarmonyOS SDK and signing files are configured.
3. Sync dependencies if the IDE prompts for Hvigor plugin setup.
4. Build and run the `entry` module on a HarmonyOS device or emulator.

## Notes

- The implementation uses `@ohos.*` imports and the V1 decorator model.
- Navigation is based on `NavPathStack`.
- `PhotoViewPicker` is used for image selection without requesting broad media permissions.
- Favorites are stored locally on device.
