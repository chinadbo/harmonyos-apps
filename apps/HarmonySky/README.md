# HarmonySky — 鸿蒙离线观星应用

纯离线天文算法应用：月相、日月升落、观星清单全部由本地算法计算，**不联网、不申请任何权限、不收集任何数据**。

## 功能

| 模块 | 说明 |
|------|------|
| 今日天象（Index） | 今日月相大图 + 月龄/照亮比/地月距离/下一次朔望倒计时 + 日月升落 + 今晚观星指数 |
| 月相日历（MoonCalendar） | 整月月相网格（每日小月相图）+ 月份切换 + 四相标记 + 点选任意日查看详情 |
| 日月升落（SunMoon） | 12 个预设城市切换 + 日出日落/晨光暮光/正午/昼长 + 月出月落/升降方位角，极昼极夜自动标注 |
| 观星清单（StarList） | 22 个观测目标（亮星/深空天体/流星雨），按季节与难度筛选，打卡进度条 |
| 天体详情（StarDetail） | 知识卡：视星等/赤经赤纬/观测建议 + 今晚观测窗口（结合当前月相）+ 打卡持久化 |
| 天文知识卡（Learn） | 8 张翻卡：太阳系/月球/恒星/深空天体/黄道/流星雨/观星礼仪/器材入门，翻面看冷知识 |
| 设置（Settings） | 12 个预设城市 + 自定义经纬度 + 深空暗色主题开关 + 关于/精度说明 |
| 桌面月相 Widget | 2x2 桌面卡片：今日月相 Canvas 绘制 + 照亮比/月龄，点击进入应用，每日定时刷新 |

## 架构

- **ArkTS，V1 装饰器体系**（@Component/@State/@Prop/@Link/@StorageProp/@StorageLink/@BuilderParam/@Watch），全项目无 V2 装饰器
- **import 风格**：全部 `@ohos.*`（`@ohos.router`、`@ohos.data.preferences`、`@ohos.window`、`@ohos.app.form.*` 等）
- **算法与 UI 分离**：`engine/` 为纯 ArkTS 算法库，无任何 UI 依赖
- **状态共享**：Preferences 在 EntryAbility onCreate 初始化，城市/坐标/主题经 AppStorage + @StorageProp/@StorageLink 跨页共享
- **权限**：0 个（module.json5 requestPermissions 为空，符合隐私最优）

### 核心算法
- 儒略日（JD）、月相（基于 2000-01-06 18:14 UTC 朔点，朔望月 29.53058867 天，含摄动修正）
- 照亮比 `(1-cos(2πφ))/2`；日月升落基于太阳/月亮赤纬 + 时角公式，含大气折射修正（-0.833°），极昼极夜返回"—"并标注
- Canvas 2D 绘制月相（外缘半圆 + 明暗界线椭圆弧）、星空闪烁动画（定时器重绘）

## 构建方式

1. DevEco Studio（API 12+ / HarmonyOS 5.0）打开工程根目录
2. File → Project Structure → Signing Configs 配置签名（或使用自动签名）
3. Build → Build Hap(s)，或直接 Run 到真机/模拟器
4. 添加桌面卡片：长按应用图标 → 服务卡片 → 添加「MoonWidget」2x2 卡片

> `entry/src/main/resources/base/media/icon.png` 为 1x1 合法 PNG 占位，请用 Asset Studio 替换为正式图标（`AppScope` 与 `widget` 下的 icon 同理）。

## 文件清单

### 工程配置
```
build-profile.json5                                # 工程构建配置（entry + widget 模块）
oh-package.json5                                   # 工程级依赖
AppScope/app.json5                                 # 应用级配置（bundle/version/icon/label）
AppScope/resources/base/element/string.json        # 应用名
AppScope/resources/base/media/icon.png             # 应用图标（占位 PNG）
AppScope/resources/base/media/README.txt           # 图标占位说明
privacy_statement.json → entry/src/main/resources/base/profile/privacy_statement.json
```

### entry 模块
```
entry/oh-package.json5                             # 模块依赖
entry/src/main/module.json5                        # 模块配置（abilities/pages/权限为空）
entry/src/main/resources/base/element/string.json  # 模块字符串
entry/src/main/resources/base/element/color.json   # 颜色资源（启动背景/主题色）
entry/src/main/resources/base/media/icon.png       # 模块图标
entry/src/main/resources/base/profile/main_pages.json        # 7 个页面路由注册
entry/src/main/resources/base/profile/privacy_statement.json # 隐私声明（无数据收集）

entry/src/main/ets/entryability/EntryAbility.ets   # 入口 Ability（Preferences 初始化 + AppStorage 共享）

entry/src/main/ets/engine/astro.ts                 # 儒略日/月相/照亮比/月距/朔望计算（纯算法）
entry/src/main/ets/engine/sunmoon.ts               # 日月升落时刻（SunCalc 算法移植，含极昼极夜）
entry/src/main/ets/engine/stardata.ts              # 22 个观星目标 + 8 张知识卡静态数据
entry/src/main/ets/model/models.ts                 # 数据模型（City/MoonInfo/SunTimes/StarTarget/LearnCard）+ 城市表
entry/src/main/ets/utils/prefs.ts                  # Preferences 封装（get/put + flush）
entry/src/main/ets/utils/format.ts                 # 日期/角度/百分比/季节提示格式化

entry/src/main/ets/components/MoonPhaseCanvas.ets  # 月相 Canvas 绘制组件（@Watch 驱动重绘）
entry/src/main/ets/components/StarSkyCanvas.ets    # 星空背景 Canvas（渐变银河 + 定时闪烁）
entry/src/main/ets/components/SkyCard.ets          # 数据卡片容器（@BuilderParam 插槽）
entry/src/main/ets/components/NavBar.ets           # 底部六页导航

entry/src/main/ets/pages/Index.ets                 # ① 今日天象
entry/src/main/ets/pages/MoonCalendar.ets          # ② 月相日历
entry/src/main/ets/pages/SunMoon.ets               # ③ 日月升落
entry/src/main/ets/pages/StarList.ets              # ④ 观星清单
entry/src/main/ets/pages/StarDetail.ets            # ⑤ 天体详情（知识卡 + 打卡）
entry/src/main/ets/pages/Learn.ets                 # ⑥ 天文知识翻卡
entry/src/main/ets/pages/Settings.ets              # ⑦ 设置
```

### widget 模块（桌面月相卡片）
```
widget/oh-package.json5                            # 模块依赖
widget/src/main/module.json5                       # FormExtensionAbility 声明 + form_config 元数据
widget/src/main/resources/base/profile/form_config.json  # 卡片配置（2x2，ArkTS 卡片，每日刷新）
widget/src/main/resources/base/element/string.json # 卡片字符串
widget/src/main/resources/base/element/color.json   # 卡片颜色
widget/src/main/resources/base/media/icon.png      # 模块图标
widget/src/main/ets/MoonWidget.ets                # FormExtensionAbility（onAddForm 注入月相数据）
widget/src/main/ets/MoonWidgetCard.ets             # 卡片 UI（Canvas 月相 + 点击跳应用）
widget/src/main/ets/widgetCalc.ts                  # Widget 专用精简月相算法（模块独立副本）
```

## 精度说明

月相时刻误差约 ±1 分钟，日月升落误差约 ±2 分钟（未含地形遮挡），仅供业余观星参考，不建议用于导航或专业用途。
