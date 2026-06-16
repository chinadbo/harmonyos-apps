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

## 项目特定规范（HarmonyBirth）

### 核心功能
1. 联系人生日档案（姓名、关系、生日 MM-DD、头像色）
2. 智能提醒（提前 1/3/7/30 天，reminderAgentManager 日历型）
3. 祝福消息模板（内置 20+ 条，支持 {name} 替换）
4. 礼物心愿单（礼物名/价格/URL/备注/已送状态）
5. Widget 小组件（2x2 显示最近 3 个生日）

### 数据库表
- contacts: id, name, relation, birthday(MM-DD), birthday_year, avatar_color, reminder_days(JSON串), note, system_contact_id, created_at
- gifts: id, contact_id, name, price, url, note, status(pending/sent), created_at

### 日期计算
- birthday 格式为 'MM-DD'（不含年）
- daysUntilBirthday: 计算距今天数，跨年考虑下一年

### API 使用
- 数据库：@ohos.data.relationalStore
- 通知：@ohos.notificationManager + reminderAgentManager
- 通讯录（可选）：@ohos.contact（需 READ_CONTACTS 权限）
- Widget：@ohos.app.form.FormExtensionAbility + formBindingData + formProvider

### 文件结构（严格遵守）
```
harmony-birth/
├── AppScope/
│   ├── app.json5
│   └── resources/base/element/string.json
├── entry/
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── entryability/EntryAbility.ets
│   │   │   ├── pages/
│   │   │   │   ├── Index.ets
│   │   │   │   ├── ContactListPage.ets
│   │   │   │   ├── AddContactPage.ets
│   │   │   │   ├── ContactDetailPage.ets
│   │   │   │   ├── TemplatePage.ets
│   │   │   │   ├── CalendarPage.ets
│   │   │   │   └── SettingsPage.ets
│   │   │   ├── components/
│   │   │   │   ├── BirthdayCard.ets
│   │   │   │   ├── CountdownBadge.ets
│   │   │   │   ├── GiftItem.ets
│   │   │   │   ├── TemplateItem.ets
│   │   │   │   └── EmptyState.ets
│   │   │   ├── model/
│   │   │   │   ├── Contact.ets
│   │   │   │   ├── Gift.ets
│   │   │   │   └── Template.ets
│   │   │   ├── database/
│   │   │   │   ├── DatabaseHelper.ets
│   │   │   │   ├── ContactDao.ets
│   │   │   │   └── GiftDao.ets
│   │   │   └── utils/
│   │   │       ├── DateUtils.ets
│   │   │       ├── NotificationUtils.ets
│   │   │       └── ShareUtils.ets
│   │   ├── module.json5
│   │   └── resources/
│   │       ├── base/
│   │       │   ├── element/string.json
│   │       │   └── profile/
│   │       │       ├── main_pages.json
│   │       │       └── form_config.json
│   │       └── rawfile/templates.json
│   ├── build-profile.json5
│   └── oh-package.json5
├── build-profile.json5
├── oh-package.json5
├── hvigorfile.ts
├── privacy_statement.json
└── README.md
```
