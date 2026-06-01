# HarmonyOS 编码规范（必须遵守）

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
- PlayMode 是系统动画枚举，自定义播放模式枚举命名避免冲突（用 MusicPlayMode 等）
- onContinue 返回值类型是 AbilityConstant.OnContinueResult，不是 string
- getContext() 不能强转为 Ability 实例
- NavPathStack 是 Navigation 内置能力，无需从任何模块显式 import
- getRdbStore 必须使用 2 参数版本（context, config），不用 4 参数版本
- FormExtensionAbility 必须同时实现 onCreate 和 onNewWant
- postCardAction 中 params 的所有值必须为字符串类型，不能是数字或对象
- Canvas 必须先 new RenderingContextSettings(true) 再 new CanvasRenderingContext2D(settings)，在 onReady 中绘制
- AppStorage 使用前必须初始化，@StorageLink 在子组件中需赋初始值

## 项目必备文件
- AppScope/app.json5 + resources/base/element/string.json + resources/base/media/app_icon.png
- entry/src/main/module.json5
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json
- entry/src/main/resources/base/profile/form_config.json
- entry/src/main/resources/base/element/string.json
- build-profile.json5 + oh-package.json5
- privacy_statement.json（隐私声明）
- README.md（功能说明 + 架构 + 构建方式）

## 权限最小化
- 只申请实际用到的权限
- 本项目只需：ohos.permission.PUBLISH_AGENT_REMINDER + ohos.permission.VIBRATE

## 本项目架构说明

### App 名称：HarmonyPack
### 功能：旅行打包清单 / 行李管理 / 出行工具

### 目录结构
```
entry/src/main/ets/
├── entryability/EntryAbility.ets
├── formability/PackFormExtensionAbility.ets
├── pages/
│   ├── Index.ets              # Navigation 主容器 + TabBar
│   ├── TripListPage.ets       # 行程列表页
│   ├── TripDetailPage.ets     # 行程详情+打包清单页
│   ├── AddTripPage.ets        # 新建/编辑行程页
│   ├── AddItemPage.ets        # 新建/编辑物品页
│   ├── TemplatePage.ets       # 场景模板列表页
│   ├── TemplateDetailPage.ets # 模板详情/应用页
│   └── StatsPage.ets          # 统计分析页
├── components/
│   ├── TripCard.ets           # 行程卡片组件
│   ├── ItemRow.ets            # 物品行组件（含 Checkbox）
│   ├── ProgressRing.ets       # Canvas 进度圆环
│   ├── CategoryGroup.ets      # 分类折叠组
│   └── StatsChart.ets         # Canvas 统计图表
├── model/
│   ├── Trip.ets
│   ├── Item.ets
│   ├── Template.ets
│   └── Constants.ets          # 品类/类型常量枚举
├── database/
│   ├── DatabaseHelper.ets     # RDB 单例 + 初始化
│   ├── TripDao.ets
│   ├── ItemDao.ets
│   └── TemplateDao.ets
├── service/
│   ├── ReminderService.ets    # reminderAgentManager 封装
│   └── WidgetService.ets      # Widget 数据推送
└── widget/pages/
    └── WidgetCard.ets
```

### 路由规范
- 使用 Navigation + NavPathStack（@Provide/@Consume 传递）
- 路由名：trip_list / trip_detail / add_trip / add_item / template_list / template_detail / stats

### 数据库规范
```typescript
import relationalStore from '@ohos.data.relationalStore'
// 使用 2 参数 getRdbStore
const store = await relationalStore.getRdbStore(context, {
  name: 'harmonypack.db',
  securityLevel: relationalStore.SecurityLevel.S1
})
```

### Widget 规范
- PackFormExtensionAbility 同时实现 onCreate 和 onNewWant
- form_config.json 定义 PackProgress 卡片，支持 2*2 和 4*2
- postCardAction params 全部为字符串

### 提醒规范
```typescript
import reminderAgentManager from '@ohos.reminderAgentManager'
// 使用 REMINDER_TYPE_CALENDAR 定时提醒
// 出发前 24h 和 2h 各一条
```

### 内置模板数据（rawfile/templates.json）
包含4个内置模板：商务出差 / 休闲度假 / 海外游 / 背包客
每个模板包含 15-25 个物品，按分类分组

### 统计功能
- 近6次出行打包完成率（Canvas 折线图）
- 最常漏带物品 Top5（基于历史 is_packed=false 记录统计）
- 本月出行次数

### 物品分类常量
clothes（衣物）/ documents（证件）/ electronics（电子设备）/ toiletries（洗漱用品）/ medicine（药物）/ other（其他）

### 行程类型常量  
business（商务出差）/ leisure（休闲度假）/ abroad（海外游）/ backpack（背包客）
