# HarmonyTorch

HarmonyOS 手电筒应用，支持多种模式和个性化设置。

## 功能特性

- **四种手电筒模式**：
  - 常亮模式：持续稳定照明
  - SOS 模式：国际求救信号 [短-短-短-长-长-长-短-短-短]
  - 频闪模式：1-20Hz 可调频率闪烁
  - 屏幕补光模式：全屏白色背景补光，支持亮度调节

- **安全设计**：
  - 应用切换到后台自动关闭手电筒
  - 最小权限申请（仅 CAMERA 和 VIBRATE）
  - 定时器清理，防止内存泄漏

- **个性化设置**：
  - 振动反馈开关
  - 屏幕常亮开关
  - 默认模式选择
  - 频闪频率调节

## 项目架构

```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets      # 入口 Ability，后台自动关闭手电筒
├── models/
│   └── TorchMode.ets         # 模式枚举和设置接口
├── services/
│   └── TorchService.ets      # 手电筒核心服务（单例）
├── utils/
│   └── PreferenceUtil.ets    # 设置持久化工具
├── components/
│   ├── TorchButton.ets       # 大圆形开关按钮
│   ├── BrightnessSlider.ets  # 亮度滑块组件
│   └── ModeCard.ets          # 模式选择卡片
└── pages/
    ├── Index.ets             # 主页面
    ├── ModeSelectPage.ets    # 模式选择页面
    └── SettingsPage.ets      # 设置页面
```

## 构建方式

使用 DevEco Studio 或命令行构建：

```bash
# 进入项目目录
cd harmony-torch

# 构建 HAP 包
hvigor assembleHap
```

## 技术规范

- **API 版本**：12 (HarmonyOS 5.0.0)
- **装饰器**：V1 (`@Component`, `@State`, `@Prop`, `@Link` 等)
- **导入风格**：`@ohos.*` 模块风格
- **主题**：暗色主题，金色强调色

## 权限声明

| 权限 | 用途 |
|------|------|
| `ohos.permission.CAMERA` | 控制设备闪光灯 |
| `ohos.permission.VIBRATE` | 开关手电筒时的振动反馈 |

> 注：CAMERA 权限仅用于控制闪光灯，不访问任何图像数据。
