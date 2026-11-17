# HarmonyPeriodic 元素周期表

基于 HarmonyOS Stage 模型的元素周期表应用，支持手机与平板，**零权限、纯离线**。

## 功能

| 页面 | 说明 |
| --- | --- |
| `pages/Index` | 首页：元素周期表总览与分类筛选 |
| `pages/ElementDetail` | 元素详情：基本属性、分类、简介 |
| `pages/FavoritesPage` | 收藏列表 |
| `pages/QuizPage` | 元素知识测验 |
| `pages/QuizResult` | 测验结果与错题回顾 |
| `pages/SettingsPage` | 设置与隐私声明展示 |

当前批次为项目骨架，各页面为占位实现，后续批次填充业务逻辑。

## 架构

- **模型**：Stage 模型，单 HAP 模块 `entry`
- **UI**：ArkTS 声明式 UI，统一使用 V1 装饰器（`@Component` + `@State/@Prop/@Link/@StorageProp/@StorageLink`），不使用 V2 体系
- **依赖风格**：统一 `@ohos.*` 导入（如 `@ohos.app.ability.UIAbility`），不使用 `@kit.*`
- **数据**：元素数据、题库随包分发，收藏/设置/答题记录写入本机应用沙箱（Preferences），无网络请求
- **权限**：`requestPermissions` 为空数组，不申请任何 `ohos.permission`

### 目录结构

```
AppScope/
  app.json5                        应用级配置（bundleName/version）
  resources/base/element/         应用名称
  resources/base/media/           应用图标
entry/
  build-profile.json5             模块构建配置
  oh-package.json5                模块依赖
  src/main/module.json5           模块与 Ability 声明
  src/main/ets/entryability/      EntryAbility 入口
  src/main/ets/pages/             6 个页面
  src/main/resources/base/        字符串、颜色、页面清单、图标
  src/main/resources/rawfile/     privacy_statement.json 隐私声明
build-profile.json5               产品与模块构建配置
oh-package.json5                  工程依赖
hvigorfile.ts                     hvigor 构建脚本
```

## 构建方式

1. 使用 DevEco Studio 5.0.0 及以上版本（API 12 / HarmonyOS 5.0.0）打开工程根目录
2. 等待 Sync 完成（hvigor 与 ohpm 依赖同步）
3. 连接真机或启动手机/平板模拟器
4. 点击 Run 'entry'，或使用菜单 Build > Build Hap(s)/APP(s)

命令行构建需先配置 hvigor 环境，然后在工程根目录执行：

```bash
hvigorw assembleHap --mode module -p product=default
```

构建产物位于 `entry/build/default/outputs/default/`。

## 隐私

应用不收集任何个人信息、不申请系统权限、不联网，详见
`entry/src/main/resources/rawfile/privacy_statement.json`。

## 备注

- `AppScope/resources/base/media/app_icon.png` 与 `entry/src/main/resources/base/media/startIcon.png`
  当前为占位图标，发布前请替换为正式设计资源。
