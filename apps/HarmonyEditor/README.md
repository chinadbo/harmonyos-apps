# HarmonyEditor

HarmonyEditor is a HarmonyOS ArkTS app for creating short-form video edits on-device. It provides a lightweight editing flow for picking clips from the media library, arranging and trimming them on a timeline, applying per-clip filters, mixing an audio track, exporting the result, and managing project defaults.

## Features

- **Project list** — browse existing drafts and exported projects, reopen them, or delete them
- **Video picker** — read videos from the local media library, preview thumbnails, and select up to 10 clips for a project
- **Editor** — review clips, reorder them, trim the selected range, add or replace an audio track, and jump to filters or export
- **Filters** — apply a filter preset and intensity to a specific clip
- **Export** — choose output resolution and format, show export progress, and save the result to the gallery
- **Settings** — manage default export resolution, format, autosave, and clear local export cache files

## Project structure

```text
HarmonyEditor/
├── AppScope/
│   ├── app.json5
│   └── resources/
├── entry/
│   ├── src/main/
│   │   ├── module.json5
│   │   ├── ets/
│   │   │   ├── entryability/
│   │   │   │   └── EntryAbility.ets
│   │   │   ├── common/
│   │   │   │   ├── constants.ts
│   │   │   │   ├── styles.ts
│   │   │   │   └── utils.ts
│   │   │   ├── model/
│   │   │   │   ├── ProjectModel.ets
│   │   │   │   ├── VideoModel.ets
│   │   │   │   └── DataStore.ets
│   │   │   ├── services/
│   │   │   │   ├── PermissionService.ets
│   │   │   │   ├── VideoEditorService.ets
│   │   │   │   └── ExportService.ets
│   │   │   ├── components/
│   │   │   │   ├── ProgressRing.ets
│   │   │   │   ├── FilterItem.ets
│   │   │   │   ├── ProjectCard.ets
│   │   │   │   ├── VideoThumbnail.ets
│   │   │   │   ├── TimelineHandle.ets
│   │   │   │   └── TimelineTrack.ets
│   │   │   └── pages/
│   │   │       ├── ProjectListPage.ets
│   │   │       ├── VideoPickerPage.ets
│   │   │       ├── EditorPage.ets
│   │   │       ├── FilterPanelPage.ets
│   │   │       ├── ExportPage.ets
│   │   │       └── SettingsPage.ets
│   │   └── resources/
│   │       └── base/
│   │           ├── element/
│   │           │   ├── color.json
│   │           │   └── string.json
│   │           └── profile/
│   │               └── main_pages.json
│   ├── hvigorfile.ts
│   └── oh-package.json5
├── build-profile.json5
├── hvigorfile.ts
├── oh-package.json5
└── README.md
```

## Architecture overview

### Common layer

- `common/constants.ts` — route constants, export and filter enums, settings keys, selection limits
- `common/styles.ts` — shared colors, spacing, radius, and layout constants
- `common/utils.ts` — duration formatting, file-size formatting, output-path helpers, progress normalization

### Model layer

- `ProjectModel.ets` — project, segment, audio track, and export settings types plus factory helpers
- `VideoModel.ets` — gallery video metadata extraction using `AVMetadataExtractor`
- `DataStore.ets` — relational store wrapper for projects, segments, audio tracks, and settings tables

### Service layer

- `PermissionService.ets` — read/write media permission requests through `@ohos.abilityAccessCtrl`
- `VideoEditorService.ets` — trim, concat, filter, audio mix, and export composition around `@ohos.multimedia.videoEditor`
- `ExportService.ets` — export orchestration and saving output files to the gallery

### Component layer

- `ProjectCard.ets` — project summary card used on the project list
- `VideoThumbnail.ets` — reusable gallery thumbnail with selection and quick preview affordances
- `TimelineTrack.ets` / `TimelineHandle.ets` — timeline trim UI for the editor
- `FilterItem.ets` — filter preset tile
- `ProgressRing.ets` — progress UI for export state

### Page flow

1. `ProjectListPage` — start new project or open an existing one
2. `VideoPickerPage` — select up to 10 clips from the media library
3. `EditorPage` — review clips, trim, reorder, add audio, open filters, or export
4. `FilterPanelPage` — configure per-clip filter type and intensity
5. `ExportPage` — choose export settings and render the final output
6. `SettingsPage` — manage defaults and local cache cleanup

## Routing

The app uses `entry/src/main/resources/base/profile/main_pages.json` for page registration and `entry/src/main/ets/common/constants.ts` for route names:

- `pages/ProjectListPage`
- `pages/VideoPickerPage`
- `pages/EditorPage`
- `pages/FilterPanelPage`
- `pages/ExportPage`
- `pages/SettingsPage`

Use the `ROUTES` constants instead of hardcoded route strings when pushing URLs.

## Data storage

HarmonyEditor stores project state locally using `@ohos.data.relationalStore`.

### Tables

- `projects` — project metadata, output path, timestamps, and export status
- `video_segments` — selected source clips, trim bounds, ordering, filter type, and filter intensity
- `audio_tracks` — one mixed audio track per project with volume and fade settings
- `settings` — persisted defaults for export resolution, format, and autosave

## Platform APIs

| API | Usage |
|---|---|
| `@ohos.multimedia.videoEditor` | Video trim, concat, filter, audio mix, export composition |
| `@ohos.multimedia.media` | Metadata extraction through `AVMetadataExtractor` |
| `@ohos.file.photoAccessHelper` | Media-library video access |
| `@ohos.file.picker` | Audio file picking |
| `@ohos.data.relationalStore` | Local project/settings storage |
| `@ohos.abilityAccessCtrl` | Runtime permission requests |
| `@ohos.file.fs` | Output-file and cache-file management |

## Permissions

The entry module currently requests:

- `ohos.permission.READ_MEDIA` — read videos selected for editing
- `ohos.permission.WRITE_MEDIA` — save exported videos to the gallery

## Development notes

- This project uses **ArkTS V1 decorators only** (`@Entry`, `@Component`, `@State`, `@Prop`, `@Link`, `@StorageProp`, `@StorageLink`)
- System imports follow the **`@ohos.*`** style only
- Video editor handles should be released promptly after each operation to avoid memory growth
- Long-running async operations should surface visible progress to the user
- `VideoEditorService` includes a defensive fallback that copies the first source clip to the output path when the system video-editor API is unavailable

## Running the project

1. Open the project in **DevEco Studio**
2. Let HarmonyOS dependencies sync for the `entry` module
3. Build or run the `entry` module on a compatible HarmonyOS device or emulator
4. Grant media permissions when prompted so the app can read source videos and save exports

> Note: this repository does not include a Node-based test suite, npm scripts, or lint configuration. The current workflow is based on HarmonyOS project build/run tooling.

## Current repo notes

- The codebase includes a root `architecture.md` reference one level above the project directory
- A root `privacy_statement.json` is included to document local media permission usage and on-device data storage
