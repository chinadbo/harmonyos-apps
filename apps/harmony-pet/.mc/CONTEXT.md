# HarmonyOS 编码规范（必须遵守）

## 装饰器体系
- 统一使用 V1 体系：@Component + @State/@Prop/@Link/@StorageProp/@StorageLink
- 禁止使用 @ComponentV2/@ObservedV2/@Trace/@Param/@Local/@Monitor/@Computed
- 禁止在同一项目中混用 V1 和 V2 装饰器

## Import 风格
- 统一使用 @ohos.* 风格（如 `import media from '@ohos.multimedia.media'`）
- 不使用 @kit.* 风格

## 常见陷阱（禁止踩坑）
- BasicDataSource 不是框架内置类，必须自行实现 IDataSource 接口
- fs.listFile() 返回 string[]，不是迭代器，没有 .next() 方法
- 不存在 media.fetchAVFileDescriptor，获取音频 metadata 用 media.createAVMetadataExtractor()
- @Reusable 只用于 V1 @Component，不用于 @ComponentV2
- PlayMode 是系统动画枚举，自定义播放模式枚举命名避免冲突（用 MusicPlayMode 等）
- onContinue 返回值类型是 AbilityConstant.OnContinueResult，不是 string
- getContext() 不能强转为 Ability 实例
- PhotoViewPicker 不传 context（new photoAccessHelper.PhotoViewPicker()，不传任何参数）
- Canvas 使用：先 new RenderingContextSettings(true) 再 new CanvasRenderingContext2D(settings)，在 onReady 回调中绘制
- getRdbStore 使用 2 参数写法：relationalStore.getRdbStore(context, config)
- reminderAgentManager 最多 30 个提醒，超出要用 evictOldest 降级
- Widget postCardAction 参数必须为字符串（JSON.stringify 转换）
- FormExtensionAbility 数据通信使用 AppStorage

## 项目必备文件
- AppScope/app.json5 + resources
- entry/src/main/module.json5
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json
- build-profile.json5 + oh-package.json5
- privacy_statement.json（隐私声明）
- README.md（功能说明 + 架构 + 构建方式）

## 权限最小化
- 只申请实际用到的权限
- READ_MEDIA 范围太大，优先用 READ_IMAGEVIDEO 等细分权限

## 本项目特定规范（HarmonyPet）

### 架构规范
- 路由：NavPathStack 统一管理，所有页面注册 main_pages.json
- 数据库：DatabaseHelper 单例，5 张表（pets/weight_records/feed_logs/health_events/pet_photos）
- 图表：Canvas 自绘折线图，WeightChart.ets 组件化

### 页面清单
1. Index.ets — 宠物列表首页
2. PetDetail.ets — 宠物详情（Tabs：概览/体重/喂食/健康/相册）
3. EditPet.ets — 添加/编辑宠物表单
4. WeightLog.ets — 体重记录 + Canvas 折线图
5. FeedLog.ets — 喂食日志 + 添加记录
6. HealthEvent.ets — 健康事件时间线
7. PhotoWall.ets — 照片墙 WaterFlow
8. ReminderSettings.ets — 提醒配置

### 组件清单
- PetCard.ets — 宠物卡片
- WeightChart.ets — Canvas 折线图
- FeedItem.ets — 喂食记录行
- HealthItem.ets — 健康事件行
- PhotoItem.ets — 照片格子

### 数据模型（model/）
- Pet.ets / WeightRecord.ets / FeedLog.ets / HealthEvent.ets / PetPhoto.ets

### DAO 层（database/）
- DatabaseHelper.ets（单例+建表）
- PetDao.ets / WeightDao.ets / FeedDao.ets / HealthDao.ets / PhotoDao.ets

### 服务层（service/）
- ReminderService.ets — reminderAgentManager 封装
- NotificationService.ets — 疫苗到期通知

### Widget
- FeedWidgetAbility.ets（FormExtensionAbility）
- widget/FeedWidget.ets（2×2 卡片）

### 目标代码量
- ~1800 行 ArkTS，28 个文件
- 完成度优先：每个功能实现核心逻辑，不做过多样式细节
