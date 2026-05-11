# HarmonyDiary

HarmonyDiary 是一个基于 HarmonyOS ArkTS 的加密日记与心情记录应用，使用 V1 装饰器体系与 `@ohos.*` import 风格实现。

## 功能特性

- AES-256-GCM 本地加密存储日记正文与标题
- HUKS 主密钥管理，别名固定为 `harmony_diary_master_key`
- RDB 持久化与 FTS5 搜索索引
- `photoAccessHelper` 图片选取并立即复制到应用沙箱
- 首页、月历、统计三标签页
- 自定义月历 Grid 组件
- Canvas 心情占比饼图
- 支持搜索、详情查看、编辑与新建

## 目录结构

```text
HarmonyDiary/
├── AppScope/
├── entry/src/main/ets/
│   ├── components/
│   ├── entryability/
│   ├── model/
│   ├── pages/
│   ├── service/
│   ├── utils/
│   └── views/
├── build-profile.json5
├── oh-package.json5
├── privacy_statement.json
└── README.md
```

## 架构说明

### UI 层

- `pages/Index.ets`：应用入口与 `NavPathStack` 容器
- `views/HomeTab.ets`：最近日记与快捷入口
- `views/CalendarTab.ets`：月历视图与按日跳转
- `views/StatsTab.ets`：统计概览与饼图
- `views/DiaryEditor.ets`：新建和编辑日记
- `views/DiaryDetail.ets`：解密展示详情
- `views/SearchPage.ets`：FTS5 搜索结果页

### 数据层

- `service/CryptoService.ets`：HUKS 密钥与 AES-256-GCM 加解密
- `service/DiaryRepository.ets`：RDB 表结构、增删改查、FTS5 搜索、统计
- `service/ImageService.ets`：系统选图与复制到沙箱

### 模型与工具

- `model/DiaryModel.ets`：核心数据结构与枚举
- `utils/DateUtils.ets`：日期、月历网格、摘要与连续天数计算
- `utils/MoodConfig.ets`：心情映射、文案与颜色配置

## 加密与存储策略

- 标题和正文分别独立加密，算法为 AES-256-GCM
- 每次加密生成新的 12-byte IV
- 数据库存储密文和 IV，不直接保存完整明文
- 搜索索引表 `diary_fts` 仅保存标题与正文前 100 字摘要的明文拼接
- 图片复制到 `filesDir/images/` 后再引用，避免直接依赖系统相册 URI

## 数据表设计

### diaries

- `id`: 主键
- `date`: 记录日期，唯一
- `mood`: 心情枚举值
- `title_iv` / `title_cipher`: 标题加密字段
- `content_iv` / `content_cipher`: 正文加密字段
- `image_paths`: 沙箱图片路径 JSON
- `created_at` / `updated_at`: 时间戳

### diary_fts

- `diary_id`: 关联日记 ID
- `content`: 标题 + 前 100 字摘要

## 构建方式

1. 使用 DevEco Studio 打开工程根目录 `HarmonyDiary`
2. 同步 `oh-package.json5` 与 `build-profile.json5`
3. 选择 `entry` 模块运行到 HarmonyOS 设备或模拟器
4. 首次选图时授予图片读取权限

## 已知说明

- 当前实现以本地单设备使用为目标，不包含云同步
- 搜索能力基于摘要索引，不会检索完整正文全部内容
- 代码遵循最小权限原则，仅申请 `ohos.permission.READ_IMAGEVIDEO`
