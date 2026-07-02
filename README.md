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
| 17 | 2026-05-18 | HarmonyNote | Markdown笔记/效率工具 | ✅ |
| 18 | 2026-05-19 | HarmonyExpress | 快递追踪/物流管理 | ✅ |
| 19 | 2026-05-20 | HarmonyCalc | 计算器/科学计算/单位换算/汇率 | ✅ |
| 20 | 2026-05-22 | HarmonyPhoto | 相册管理/照片编辑/滤镜 | ✅ |
| 21 | 2026-05-23 | HarmonyFiles | 文件管理器 | ✅ |
| 22 | 2026-05-24 | HarmonyClip | 剪贴板管理/效率工具 | ✅ |
| 23 | 2026-05-26 | HarmonySpeed | 网速测试/网络诊断 | ✅ |
| 24 | 2026-05-27 | HarmonyCapture | 截图标注/图片编辑 | ✅ |
| 25 | 2026-05-28 | HarmonyTime | 时间追踪/生产力工具 | ✅ |
| 26 | 2026-05-29 | [HarmonySleep](apps/harmony-sleep) | 睡眠记录/健康管理 | ✅ |

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
| HarmonyPhoto | 相册管理/照片编辑/滤镜 | [apps/harmony-photo](apps/harmony-photo) | 2026-05-22 |
| HarmonyFiles | 文件管理器 | [apps/harmony-files](apps/harmony-files) | 2026-05-23 |
| harmony-speed | 网速测试/网络诊断 | HarmonySpeed | API 12 | ✅ |
| harmony-scan | HarmonyScan | 文档扫描/PDF生成/效率工具 | Camera+Canvas四角裁剪+PixelMap图像处理+PDF生成 | [查看](apps/harmony-scan) |
| HarmonyCapture | 截图标注/图片编辑/效率工具 | [apps/harmony-capture](apps/harmony-capture) | 2026-05-27 |
| HarmonyTime | 时间追踪/生产力工具 | [apps/harmony-time](apps/harmony-time) | 2026-05-28 |
| HarmonyExplore | 城市探索/景点打卡/旅行记录 | [apps/harmony-explore](apps/harmony-explore) | 2026-05-30 |
| HarmonyPack | 旅行打包清单/行李管理 | [apps/harmony-pack](apps/harmony-pack) | 2026-06-02 |
| HarmonyPet | 宠物管理助手/宠物日记/生活工具 | [apps/harmony-pet](apps/harmony-pet) | 2026-06-04 |
| HarmonyCar | 汽车保养/车辆管理/生活工具 | [apps/harmony-car](apps/harmony-car) | 2026-06-05 |
| HarmonyPalette | 设计工具/色彩工具/图片取色 | [apps/harmony-palette](apps/harmony-palette) | 2026-06-07 |
| HarmonyShop | 购物清单/采购管理/生活工具 | [apps/harmony-shop](apps/harmony-shop) | 2026-06-08 |
| HarmonyTask | 待办事项/任务管理/效率工具 | [apps/harmony-task](apps/harmony-task) | 2026-06-09 |
| HarmonyPill | 用药提醒/健康管理/生活工具 | [apps/harmony-pill](apps/harmony-pill) | 2026-06-10 |
| HarmonyHydrate | 健康饮水/生活习惯/健康管理 | [apps/harmony-hydrate](apps/harmony-hydrate) | 2026-06-12 |
| HarmonySavings | 个人储蓄目标/财务目标/理财工具 | [apps/harmony-savings](apps/harmony-savings) | 2026-06-13 |
| HarmonyNutrition | 饮食热量追踪/营养管理/健康工具 | [apps/harmony-nutrition](apps/harmony-nutrition) | 2026-06-14 |
| HarmonyBill | 账单分摊/AA制/多人分账/理财工具 | [apps/harmony-bill](apps/harmony-bill) | 2026-06-15 |
| HarmonyBirth | 生日提醒/社交辅助/联系人管理/生活工具 | [apps/harmony-birth](apps/harmony-birth) | 2026-06-17 |
| HarmonyWord | 汉字词典/语言学习/教育工具 | [apps/harmony-word](apps/harmony-word) | 2026-06-21 |
| HarmonyPoem | 古诗词/国学/教育工具 | [apps/harmony-poem](apps/harmony-poem) | 2026-06-22 |
| HarmonyGoal | 个人目标管理/OKR追踪/成长工具 | [apps/harmony-goal](apps/harmony-goal) | 2026-06-23 |
| HarmonyMind | 思维导图/脑图/知识管理 | [apps/harmony-mind](apps/harmony-mind) | 2026-06-24 |
| HarmonyPuzzle | 拼图游戏/益智 | [apps/harmony-puzzle](apps/harmony-puzzle) | 2026-06-28 |
| HarmonyTempo | 节拍器/音乐工具 | [apps/harmony-tempo](apps/harmony-tempo) | 2026-07-02 |
| HarmonyCompass | 指南针/方向工具 | [apps/harmony-compass](apps/harmony-compass) | 2026-07-03 |
