# HarmonyOS Daily Apps

每日一个纯血鸿蒙 App，目标上架 AppGallery。

## Apps

| # | 日期 | App | 品类 | 状态 |
|---|------|-----|------|------|
| 1 | 2026-04-23 | HarmonyBeats | 音乐播放器 | ✅ |
| 2 | 2026-04-24 | HarmonyVault | 密码管理器 | ✅ |
| 3 | 2026-04-26 | HarmonyTune | 音乐播放器 | ✅ |
| 4 | 2026-04-28 | HarmonyFeed | RSS 阅读器 | 🚧 |
| 5 | 2026-04-30 | HarmonyPlayer | 音乐播放器 | ✅ |
| 6 | 2026-05-01 | HarmonyFocus | 番茄钟/专注计时 | ✅ |
| 7 | 2026-05-04 | HarmonyLedger | 记账/预算管理 | ✅ |
| 8 | 2026-05-06 | HarmonyHabit | 习惯追踪/打卡 | ✅ |
| 9 | 2026-05-07 | HarmonyWeather | 天气/气象 | ✅ |
| 10 | 2026-05-08 | HarmonyRecipe | 食谱/菜谱/烹饪 | ✅ |
| 11 | 2026-05-09 | HarmonyFlash | 单词闪卡/间隔重复 | ✅ |
| 12 | 2026-05-11 | HarmonyReader | 电子书阅读器 | ✅ |
| 13 | 2026-05-12 | HarmonyDiary | 日记/心情记录 | ✅ |
| 14 | 2026-05-14 | HarmonyCountdown | 倒计时/纪念日 | ✅ |
| 15 | 2026-05-16 | HarmonyQR | 二维码工具 | ✅ |
| 16 | 2026-05-17 | HarmonyFit | 健康/运动记录 | ✅ |

## 技术栈

- HarmonyOS 5.0+ (API 12)
- ArkTS + ArkUI
- 纯血鸿蒙原生开发（无跨平台框架）

## 目录结构

每个 App 在独立子目录中，包含完整可编译的 DevEco Studio 项目。

```
apps/
├── harmonybeats/
├── harmonyvault/
├── harmonytune/
├── harmonyfeed/
├── harmonyplayer/
├── harmony-focus/
├── harmony-ledger/
├── harmony-habit/
├── harmony-weather/
├── harmony-recipe/
├── harmony-flash/
├── harmony-reader/
├── harmony-diary/
└── harmony-countdown/
```

| 2026-05-16 | HarmonyQR | 二维码工具 | 扫码+生成+历史管理，customScan+RDB | apps/harmony-qr |

| 2026-05-18 | [HarmonyNote](apps/harmony-note) | Markdown笔记/效率工具 | ✅ completed |
