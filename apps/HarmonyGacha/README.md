# HarmonyGacha 抽卡记录助手

本地优先的 HarmonyOS 抽卡记录工具：记录每一次抽卡，跟踪各池保底进度，统计出金分布与欧非指数。零权限、零联网、零数据上传。

## 功能

- **总览（Index）**：总抽数 / 出金数 / 欧非指数大卡（NumberRoll 数字滚动动画），各池保底进度条（软保底区间高亮），最近出金动态
- **记录（RecordPage）**：按日期分组的时间线记录，按卡池 / 星级筛选，长按删除，空状态引导
- **录入（AddRecordPage）**：单条表单（卡池 / 星级 5金4紫3蓝 / 物品名 / 第几抽 / DatePicker 日期）+ 批量粘贴导入（多行文本智能解析、解析预览、确认入库）
- **统计（StatsPage）**：出金抽数分布直方图（Canvas，10 抽一档）、累计出金概率曲线（Canvas）、各池出货占比条形、欧非指数说明
- **卡池（PoolPage）**：内置 6 池展示 + 自定义池增删改，一键切换当前池（is_current）
- **设置（SettingsPage）**：主题切换（欧皇金 / 非酋蓝，全局生效）、导出全部记录 JSON（写入应用缓存目录并显示路径）、清空数据（二次确认）

## 技术要点

- ArkTS + **V1 装饰器体系**（@Component / @State / @Prop / @StorageLink / @Watch），全工程 @ohos.* import 风格
- RDB 双表（`gacha_records` / `pools`），DB 初始化失败自动降级内存模式，不崩溃
- `PityEngine`：分池 pity 计数、硬保底（角色/标准 90、武器 80）、软保底起点（74 / 66）、概率模型（基础 0.6%，软保底起每抽 +6%）、欧非指数（出金均抽数与期望 62 的比值映射 0-100）
- 首次启动预置 6 个内置卡池 + 40 条演示抽卡记录
- 主题通过 `AppStorage("gachaTheme")` + Preferences 持久化；数据变更通过 `AppStorage("refreshFlag")` 通知各页刷新
- 零权限声明（无网络 / 无媒体 / 无通知），隐私见 `privacy_statement.json`

## 工程结构

```
HarmonyGacha/
├── AppScope/                          # 应用级配置与资源
├── entry/src/main/
│   ├── ets/
│   │   ├── entryability/EntryAbility.ets   # AppStorage 预置、DB 初始化与种子数据
│   │   ├── model/                          # GachaModels（数据类）/ PresetPools（预置池与演示数据）
│   │   ├── db/GachaDb.ets                  # RDB 封装：建表 / CRUD / 内存降级
│   │   ├── engine/PityEngine.ets           # 保底与欧非计算、概率模型
│   │   ├── parser/LogParser.ets            # 粘贴文本多格式解析
│   │   ├── common/                         # Theme（主题色）/ Format（格式化）
│   │   ├── components/                     # PityBar / GoldChart / LuckCurve / NumberRoll / RecordCard / NavBar
│   │   └── pages/                          # Index / RecordPage / AddRecordPage / StatsPage / PoolPage / SettingsPage
│   ├── resources/                          # 字符串 / 颜色 / 图标 / main_pages
│   └── module.json5                        # 零 requestPermissions
├── privacy_statement.json
├── build-profile.json5
└── oh-package.json5
```

## 构建

1. DevEco Studio 打开工程根目录，自动同步 SDK（API 12+，HarmonyOS 5.0）。
2. 连接真机或启动模拟器，Run 'entry'。
3. 命令行构建：`hvigorw assembleHap --mode module -p product=default`，产物在 `entry/build/default/outputs/default/`。

## 截图

| 总览 | 记录 | 录入 |
| --- | --- | --- |
| ![Index](docs/screenshot-index.png) | ![Record](docs/screenshot-record.png) | ![Add](docs/screenshot-add.png) |

| 统计 | 卡池 | 设置 |
| --- | --- | --- |
| ![Stats](docs/screenshot-stats.png) | ![Pool](docs/screenshot-pool.png) | ![Settings](docs/screenshot-settings.png) |

## 截图占位

- [ ] 总览：保底进度条 + 欧非指数大卡
- [ ] 记录：日期时间线 + 筛选
- [ ] 录入：批量粘贴解析预览
- [ ] 统计：直方图 + 概率曲线
- [ ] 卡池管理
- [ ] 设置：主题切换 + 导出
