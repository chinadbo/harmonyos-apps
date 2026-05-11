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
- READ_MEDIA 范围太大，优先用 READ_AUDIO/READ_IMAGES 等细分权限

## 项目专属规范（HarmonyDiary）

### 加密规范
- HUKS 密钥别名：'harmony_diary_master_key'
- 算法：AES-256-GCM，每次加密重新生成 12-byte IV
- import 使用：import huks from '@ohos.security.huks'

### 数据库规范
- import 使用：import relationalStore from '@ohos.data.relationalStore'
- 所有 DB 操作在 TaskPool 中执行
- FTS5 搜索表：diary_fts（content 为标题+前100字明文）

### 图片规范
- import 使用：import photoAccessHelper from '@ohos.file.photoAccessHelper'
- 选图后立即复制到沙箱：getContext(this).filesDir + '/images/'
- 权限：ohos.permission.READ_IMAGEVIDEO

### 路由规范
- 使用 NavPathStack 统一路由
- 注册页面：pages/Index, views/DiaryEditor, views/DiaryDetail, views/SearchPage

### 心情枚举
```typescript
enum DiaryMood {
  Happy = 'happy',
  Calm = 'calm',
  Sad = 'sad',
  Angry = 'angry',
  Excited = 'excited',
  Anxious = 'anxious',
  Grateful = 'grateful'
}
```

### 文件结构（必须完整生成）
```
HarmonyDiary/
├── AppScope/app.json5
├── AppScope/resources/base/element/string.json
├── AppScope/resources/base/media/app_icon.png（用占位文件）
├── entry/src/main/ets/entryability/EntryAbility.ets
├── entry/src/main/ets/pages/Index.ets（主Tabs）
├── entry/src/main/ets/views/HomeTab.ets
├── entry/src/main/ets/views/CalendarTab.ets
├── entry/src/main/ets/views/StatsTab.ets
├── entry/src/main/ets/views/DiaryEditor.ets
├── entry/src/main/ets/views/DiaryDetail.ets
├── entry/src/main/ets/views/SearchPage.ets
├── entry/src/main/ets/components/MonthCalendar.ets
├── entry/src/main/ets/components/MoodPicker.ets
├── entry/src/main/ets/components/DiaryCard.ets
├── entry/src/main/ets/components/MoodPieChart.ets
├── entry/src/main/ets/components/EmptyState.ets
├── entry/src/main/ets/model/DiaryModel.ets
├── entry/src/main/ets/service/DiaryRepository.ets
├── entry/src/main/ets/service/CryptoService.ets
├── entry/src/main/ets/service/ImageService.ets
├── entry/src/main/ets/utils/DateUtils.ets
├── entry/src/main/ets/utils/MoodConfig.ets
├── entry/src/main/module.json5
├── entry/src/main/resources/base/element/string.json
├── entry/src/main/resources/base/profile/main_pages.json
├── entry/src/main/resources/zh_CN/element/string.json
├── build-profile.json5
├── oh-package.json5
├── privacy_statement.json
└── README.md
```
