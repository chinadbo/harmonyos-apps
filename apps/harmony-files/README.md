# HarmonyFiles

A file manager application for HarmonyOS, supporting phones, tablets, and 2-in-1 devices.

## Features

- Browse local file system directories and files
- Search files and folders by name
- File preview support (images, documents, media)
- Multi-device layout adaptation (phone, tablet, 2-in-1)
- Permission-safe media access (in-use only)

## Architecture

```
harmony-files/
├── AppScope/                          # App-level resources
│   ├── app.json5                      # Bundle config (name, version, API level)
│   └── resources/base/element/
│       └── string.json                # App name string
├── entry/                             # Main entry module
│   └── src/main/
│       ├── module.json5               # Module config (abilities, permissions)
│       ├── ets/
│       │   ├── entryability/
│       │   │   └── EntryAbility.ets   # App lifecycle entry point
│       │   └── pages/
│       │       └── Index.ets          # Main file browser page
│       └── resources/
│           ├── base/
│           │   ├── element/
│           │   │   ├── string.json    # UI strings
│           │   │   └── color.json     # Theme colors
│           │   └── profile/
│           │       └── main_pages.json  # Page routing
│           └── rawfile/
│               └── privacy_statement.json  # Permission rationale
├── build-profile.json5                # Build targets and SDK config
└── oh-package.json5                   # Package metadata and dependencies
```

### Key Design Decisions

- **API Level 12 (SDK 5.0.0)** — targets HarmonyOS NEXT for full ArkTS support
- **`ohos.permission.READ_MEDIA` (in-use)** — least-privilege media access; only active while the app is foregrounded
- **Multi-device `deviceTypes`** — single codebase adapts layout for phone, tablet, and 2-in-1

## Build Instructions

### Prerequisites

- DevEco Studio 5.0 or later
- HarmonyOS SDK 5.0.0 (API 12)

### Steps

1. Open the project in DevEco Studio:
   `File > Open > select the harmony-files directory`

2. Sync the project:
   `Build > Sync Project with oh-package.json5`

3. Connect a device or start an emulator (API level 12+).

4. Run the app:
   `Run > Run 'entry'`

   Or build a release HAP:
   `Build > Build Hap(s)/APP(s) > Build APP(s)`

### Signing (Release)

Add your signing config to `build-profile.json5` under `app.signingConfigs` and reference it in the `default` product's `signingConfig` field before building a release HAP.
