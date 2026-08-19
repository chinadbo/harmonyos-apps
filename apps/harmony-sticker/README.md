# HarmonySticker

HarmonySticker is a HarmonyOS sticker and meme maker app built with ArkUI V1 decorators. It opens directly into a simple editor where users can choose a preset background, add text stickers, select layers, move text, change sticker colors, and resize typography.

## Features

- Preset meme-style backgrounds that work without media permissions
- Multiple editable text stickers
- Sticker selection and layer list
- Position controls for moving stickers
- Font size and color controls
- Minimal permission footprint

## Architecture

- `AppScope/app.json5`: app metadata
- `entry/src/main/module.json5`: entry module definition
- `entry/src/main/ets/entryability/EntryAbility.ets`: Stage-model ability entry point
- `entry/src/main/ets/pages/HarmonyStickerPage.ets`: main editor page
- `entry/src/main/ets/components/StickerCanvas.ets`: meme preview canvas
- `entry/src/main/ets/components/StickerToolbar.ets`: editing controls
- `entry/src/main/ets/components/StickerList.ets`: sticker layer list
- `entry/src/main/ets/models/StickerModel.ets`: editor data types
- `entry/src/main/ets/common/EditorDefaults.ets`: presets and shared constants

## Build

This workspace was generated from scratch in an otherwise empty directory, so standard HarmonyOS tooling must be available locally to build it.

Typical commands in a configured HarmonyOS environment:

```bash
npm install
hvigorw assembleHap
```

If your environment uses DevEco Studio managed tooling, open the folder as a HarmonyOS project and run the default `entry` build.

## Privacy

HarmonySticker does not request gallery, media, microphone, contacts, or location permissions in this version. The editor uses bundled local presets only.
