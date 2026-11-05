# HarmonyOS 编码规范（必须遵守）

## 本项目：HarmonyCine 影视追踪与片单管理
- 架构设计见 `~/.openclaw/harmony-daily-app/today/architecture.md`，严格按模块划分/数据模型/API 规范实现
- 完整实现 6 页面 + 4 组件 + 3 数据文件 + EntryAbility，目标 30+ 文件 / 2200+ 行 ArkTS
- 所有页面必须在 entry/src/main/resources/base/profile/main_pages.json 注册

## 装饰器体系
- 统一使用 V1 体系：@Component + @State/@Prop/@Link/@StorageProp/@StorageLink
- 禁止使用 @ComponentV2/@ObservedV2/@Trace/@Param/@Local/@Monitor/@Computed
- 禁止在同一项目中混用 V1 和 V2 装饰器

## Import 风格
- 统一使用 @ohos.* 风格（如 `import relationalStore from '@ohos.data.relationalStore'`）
- 不使用 @kit.* 风格

## 常见陷阱（禁止踩坑）
- BasicDataSource 不是框架内置类，必须自行实现 IDataSource 接口
- fs.listFile() 返回 string[]，不是迭代器，没有 .next() 方法
- 不存在 media.fetchAVFileDescriptor，获取音频 metadata 用 media.createAVMetadataExtractor()
- @Reusable 只用于 V1 @Component，不用于 @ComponentV2
- PlayMode 是系统动画枚举，自定义播放模式枚举命名避免冲突（用 CinePlayMode 等）
- onContinue 返回值类型是 AbilityConstant.OnContinueResult，不是 string
- getContext() 不能强转为 Ability 实例

## 历史教训（上一项目评审 P0，本项目禁止重犯）
- 【P0-1】build-profile.json5 禁止引用 obfuscation-rules.txt（不创建该引用，直接省略 obfuscation.ruleOptions 整块）
- 【P0-2】EntryAbility 必须声明 skills：`"skills": [{ "entities": ["entity.system.home"], "actions": ["action.system.home"] }]`
- 【P0-3】windowStage.loadContent 使用 promise 版本 + try/catch BusinessError，或回调判 `if (err && err.code)`；禁止直接访问 err.code
- 【P1-1】不用 vibrator，本项目无振动需求
- 【P1-3】所有 setTimeout 必须保存 id 并在 aboutToDisappear 中 clearTimeout；页面销毁后回调禁止执行路由跳转

## 项目必备文件
- AppScope/app.json5 + AppScope/resources/base/element/string.json（app_label 等）
- entry/src/main/module.json5（零 requestPermissions，EntryAbility 带 skills 配置）
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json（注册全部 6 页面）
- entry/src/main/resources/base/element/string.json + color.json + media（icon 占位可用 layer_image 或最小 icon）
- build-profile.json5（根 + entry）+ oh-package.json5（根 + entry）+ hvigorfile.ts（根 + entry）
- entry/src/main/resources/base/profile/privacy_statement.json（声明本地存储、无数据收集）
- README.md（功能说明 + 架构 + 构建方式）

## 权限最小化
- 本项目零权限：纯 RDB + Preferences，不申请任何 ohos.permission

## 编码顺序建议
1. 配置文件（app.json5/module.json5/build-profile/oh-package/hvigorfile/main_pages）
2. model/Movie.ets（数据模型+枚举+色板）
3. data/DbService.ets → SeedData.ets → MovieRepository.ets
4. components/（RatingStars → MovieCard → StatRingChart → StatBarChart）
5. pages/（Index → AddMoviePage → MovieDetailPage → StatsPage → AchievementsPage → SettingsPage）
6. EntryAbility.ets
7. README.md + privacy_statement.json

完成后输出文件清单与总行数统计。
