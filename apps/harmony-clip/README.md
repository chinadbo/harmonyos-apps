# HarmonyClip - 智能剪贴板管理器

## 功能介绍

HarmonyClip 是一款运行在 HarmonyOS 上的智能剪贴板历史管理工具，主要功能：

- **一键粘贴读取**：通过系统 PasteButton 零权限读取剪贴板，无需申请 READ_PASTEBOARD 权限
- **历史记录管理**：自动保存剪贴板内容，支持按类型过滤（全部/文本/URL/邮箱/手机号/JSON）
- **全文搜索**：快速搜索历史剪贴内容
- **收藏夹**：长按收藏重要内容，防止被自动清理
- **隐私保护**：自动识别手机号、身份证等隐私内容并脱敏显示（●●●）
- **侧滑删除**：列表项左滑即可快速删除
- **自动过期**：可设置保留天数（7/30/90 天），过期自动清理
- **分布式同步**：开启后在账号下的多台设备间同步剪贴板历史

## 技术架构

```
HarmonyClip
├── AppScope/                       # 应用全局配置
├── entry/src/main/
│   ├── ets/
│   │   ├── entryability/
│   │   │   └── EntryAbility.ets    # Ability 入口
│   │   ├── pages/
│   │   │   ├── Index.ets           # 主页（搜索+历史列表）
│   │   │   ├── Favorites.ets       # 收藏夹页
│   │   │   └── Settings.ets        # 设置页
│   │   ├── components/
│   │   │   ├── ClipItem.ets        # 列表项组件
│   │   │   ├── TypeBadge.ets       # 类型标签组件
│   │   │   └── EmptyState.ets      # 空状态组件
│   │   ├── model/
│   │   │   └── ClipEntry.ets       # 数据模型 + IDataSource 实现
│   │   ├── database/
│   │   │   └── ClipDatabase.ets    # RDB 数据库封装（单例）
│   │   └── service/
│   │       ├── ClipDetector.ets    # 内容类型检测（正则）
│   │       └── ClipService.ets     # 业务逻辑层
│   └── resources/
└── build-profile.json5
```

### 核心技术选型

| 技术点 | 方案 |
|--------|------|
| 装饰器体系 | V1（@Component/@State/@Prop/@Link/@StorageProp） |
| 剪贴板读取 | PasteButton（无需权限） |
| 数据持久化 | @ohos.data.relationalStore（RDB） |
| 列表渲染 | LazyForEach + IDataSource |
| 页面路由 | NavPathStack |
| 内容检测 | 正则表达式（URL/邮箱/手机号/JSON） |
| 分布式 | ohos.permission.DISTRIBUTED_DATASYNC |

## 构建方式

### 环境要求

- DevEco Studio 5.0+
- HarmonyOS SDK API 12+
- 真机或 API 12 模拟器

### 构建步骤

1. 克隆项目到本地
2. 使用 DevEco Studio 打开项目根目录
3. 等待依赖同步完成
4. 连接设备或启动模拟器
5. 点击 Run 或执行 `hvigorw assembleHap`

### 签名配置

发布前需在 `build-profile.json5` 中配置签名信息，或使用 DevEco Studio 自动签名功能。

## 权限说明

| 权限 | 用途 | 类型 |
|------|------|------|
| ohos.permission.DISTRIBUTED_DATASYNC | 跨设备同步剪贴板历史 | 用户授权（可选） |

> 注：不申请 READ_PASTEBOARD 权限，使用系统提供的 PasteButton 组件读取剪贴板，保护用户隐私。

## 隐私说明

- 剪贴板内容仅保存在本地设备，不上传至任何服务器
- 隐私内容（手机号等）自动脱敏显示
- 用户可随时在设置页面清空全部历史
