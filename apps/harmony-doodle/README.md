# HarmonyDoodle

A creative drawing and doodle board application for HarmonyOS, built with ArkTS.

## Features

- **Freehand Drawing** — Multi-touch support for natural drawing experience
- **Multiple Brush Tools** — Pencil, Marker, Eraser, Highlighter
- **Shape Tools** — Line, Rectangle, Circle, Arrow
- **Color Picker** — 20 preset colors + custom opacity control
- **Layer Management** — Multiple layers with opacity and visibility control
- **Undo/Redo** — History stack with up to 20 steps per layer
- **Artwork Gallery** — Save, view, and manage your creations
- **Share** — Export and share your artwork
- **Dark Mode** — Automatic system theme adaptation

## Tech Stack

- HarmonyOS API 12
- ArkTS (TypeScript for HarmonyOS)
- Canvas 2D with OffscreenCanvas layers
- V1 decorator system (@Component, @State, @Link, @StorageProp)
- @ohos.* import style

## Architecture

```
entry/src/main/ets/
├── entryability/EntryAbility.ets    # Entry point
├── pages/
│   ├── MainPage.ets                 # Main drawing canvas
│   ├── GalleryPage.ets              # Artwork gallery
│   ├── SettingsPage.ets             # App settings
│   └── AboutPage.ets                # About info
├── engine/
│   ├── CanvasEngine.ets             # Core drawing logic
│   ├── Layer.ets                    # Layer management
│   └── HistoryManager.ets           # Undo/redo system
├── manager/
│   └── ToolManager.ets              # Tool state management
├── components/
│   ├── ColorPicker.ets              # Color selection UI
│   ├── ToolBar.ets                  # Tool selection UI
│   ├── LayerPanel.ets               # Layer management UI
│   └── BrushSizeSlider.ets          # Brush size control
├── service/
│   └── ArtworkService.ets           # Save/load with fs + preferences
└── models/
    └── Types.ets                    # Type definitions
```

## Build

```bash
# Using DevEco Studio or command line
hvigorw assembleHap
```

## Permissions

- `ohos.permission.WRITE_IMAGES` — Save artwork to gallery
- `ohos.permission.READ_IMAGES` — Read artwork from gallery

## License

MIT
