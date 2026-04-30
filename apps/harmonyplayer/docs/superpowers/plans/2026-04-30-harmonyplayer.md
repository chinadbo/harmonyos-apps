# HarmonyPlayer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete HarmonyOS local music player project scaffold named HarmonyPlayer with playback, library, AV session, insight intent, widget, persistence, and project configuration files.

**Architecture:** The app is split into an `entry` module for UI and playback logic and a `widget` module for desktop card UI. Playback state is centralized in `PlayerService` and mirrored through `AppStorage`, while persistence is handled by RDB helper/store classes and external integrations are isolated behind `AVSessionManager`, `MediaScanner`, and `PlayMusicIntentExecutor`.

**Tech Stack:** HarmonyOS API 16, ArkTS, ArkUI, AVPlayer, AVSession, RelationalStore, FormExtensionAbility, InsightIntent, AppStorage.

---

### Task 1: Scaffold project and resources

**Files:**
- Create: `AppScope/app.json5`
- Create: `AppScope/resources/base/element/string.json`
- Create: `AppScope/resources/base/media/app_icon.png`
- Create: `entry/module.json5`
- Create: `entry/oh-package.json5`
- Create: `entry/src/main/resources/base/profile/main_pages.json`
- Create: `entry/src/main/resources/base/profile/form_config.json`
- Create: `entry/src/main/resources/base/profile/privacy_statement.json`
- Create: `entry/src/main/resources/base/element/string.json`
- Create: `entry/src/main/resources/base/element/color.json`
- Create: `entry/src/main/resources/base/media/startIcon.png`
- Create: `entry/src/main/resources/base/media/default_cover.png`
- Create: `entry/src/main/resources/base/media/layered_image.json`
- Create: `widget/module.json5`
- Create: `widget/src/main/resources/base/profile/form_config.json`
- Create: `hvigor/hvigor-config.json5`
- Create: `build-profile.json5`
- Create: `oh-package.json5`

- [ ] Write the config and resource files with the required bundle name, API level, pages, widget config, and placeholder assets.
- [ ] Verify the generated file tree contains `AppScope`, `entry`, `widget`, and `hvigor`.

### Task 2: Build playback foundation

**Files:**
- Create: `entry/src/main/ets/model/SongInfo.ets`
- Create: `entry/src/main/ets/model/PlayMode.ets`
- Create: `entry/src/main/ets/model/LyricLine.ets`
- Create: `entry/src/main/ets/viewmodel/PlayerViewModel.ets`
- Create: `entry/src/main/ets/service/LyricParser.ets`
- Create: `entry/src/main/ets/service/MediaScanner.ets`
- Create: `entry/src/main/ets/service/AVSessionManager.ets`
- Create: `entry/src/main/ets/service/PlayerService.ets`
- Create: `entry/src/main/ets/database/DBHelper.ets`
- Create: `entry/src/main/ets/database/FavoriteStore.ets`
- Create: `entry/src/main/ets/database/HistoryStore.ets`

- [ ] Create the data models exactly as specified.
- [ ] Initialize AppStorage keys and playback queue state.
- [ ] Implement lyric parsing, media scanning, AV session integration, and AVPlayer lifecycle management.
- [ ] Add RDB initialization and helper store methods for favorites and history.

### Task 3: Build app UI and abilities

**Files:**
- Create: `entry/src/main/ets/entryability/EntryAbility.ets`
- Create: `entry/src/main/ets/entryformability/EntryFormAbility.ets`
- Create: `entry/src/main/ets/insightintent/PlayMusicIntentExecutor.ets`
- Create: `entry/src/main/ets/components/MiniPlayer.ets`
- Create: `entry/src/main/ets/components/SongItem.ets`
- Create: `entry/src/main/ets/components/LyricView.ets`
- Create: `entry/src/main/ets/components/AlbumCover.ets`
- Create: `entry/src/main/ets/components/ProgressBar.ets`
- Create: `entry/src/main/ets/pages/Index.ets`
- Create: `entry/src/main/ets/pages/LibraryPage.ets`
- Create: `entry/src/main/ets/pages/PlayerPage.ets`
- Create: `entry/src/main/ets/pages/PlaylistPage.ets`
- Create: `entry/src/main/ets/pages/SettingsPage.ets`

- [ ] Initialize DB, player, and AV session in `EntryAbility` and route insight intent control actions.
- [ ] Build the page and component tree using `Tabs`, `LazyForEach`, `@Reusable`, `Slider`, and `AppStorage`.
- [ ] Wire library scanning, queue interactions, playback controls, lyric scrolling, and settings persistence.

### Task 4: Build widget and docs

**Files:**
- Create: `widget/src/main/ets/widget/EntryFormAbility.ets`
- Create: `widget/src/main/ets/widget/pages/WidgetCard.ets`
- Create: `README.md`
- Create: `OUTPUT.md`

- [ ] Create widget UI and action forwarding for play or pause toggling.
- [ ] Write README with architecture diagram, features, HarmonyOS capabilities, build instructions, screenshot placeholder, and MIT license.
- [ ] Generate `OUTPUT.md` with status, full file list, and known issues.
