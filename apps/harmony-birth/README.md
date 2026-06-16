# HarmonyBirth

HarmonyBirth 是一个基于 HarmonyOS ArkTS 的生日提醒与社交辅助工具，提供联系人生日档案管理、智能提醒、祝福消息模板、礼物心愿单和 2x2 Widget 小组件。

## 功能说明

- 联系人生日档案管理：姓名、关系、生日（MM-DD）、头像色、出生年份、备注
- 智能提醒：基于 `@ohos.reminderAgentManager` 的日历型提醒，支持提前 1/3/7/30 天
- 祝福模板：内置 22 条模板，支持 `{name}` 变量替换，可复制分享
- 礼物心愿单：按联系人维护礼物名称、预算、URL、备注和送出状态
- Widget：2x2 卡片显示最近 3 个生日和倒计时

## 架构

### 页面
- `entry/src/main/ets/pages/Index.ets`：首页仪表盘
- `entry/src/main/ets/pages/ContactListPage.ets`：联系人生日列表
- `entry/src/main/ets/pages/AddContactPage.ets`：新增联系人
- `entry/src/main/ets/pages/ContactDetailPage.ets`：联系人详情与礼物心愿单
- `entry/src/main/ets/pages/TemplatePage.ets`：祝福模板页
- `entry/src/main/ets/pages/CalendarPage.ets`：生日日历视图
- `entry/src/main/ets/pages/SettingsPage.ets`：提醒设置与应用说明

### 数据层
- `entry/src/main/ets/database/DatabaseHelper.ets`：RDB 初始化与建表
- `entry/src/main/ets/database/ContactDao.ets`：联系人数据访问
- `entry/src/main/ets/database/GiftDao.ets`：礼物数据访问

### 工具层
- `entry/src/main/ets/utils/DateUtils.ets`：生日日期计算、提醒日期、日历分组
- `entry/src/main/ets/utils/NotificationUtils.ets`：提醒创建、取消、重同步
- `entry/src/main/ets/utils/ShareUtils.ets`：模板变量替换与复制分享

### Widget
- `entry/src/main/ets/widget/HarmonyBirthFormAbility.ets`：FormExtensionAbility
- `entry/src/main/ets/widget/pages/WidgetCard.ets`：2x2 小组件 UI

## 数据库结构

### contacts
- id
- name
- relation
- birthday
- birthday_year
- avatar_color
- reminder_days
- note
- system_contact_id
- created_at

### gifts
- id
- contact_id
- name
- price
- url
- note
- status
- created_at

## 构建方式

1. 使用 DevEco Studio 打开项目根目录 `harmony-birth`
2. 确保 SDK 为 HarmonyOS NEXT/Stage Model 对应版本
3. 执行 Sync Project
4. 选择 `entry` 模块运行到设备或模拟器

## 技术约束

- 全量使用 V1 装饰器体系
- 统一使用 `@ohos.*` import 风格
- 数据库存储基于 `@ohos.data.relationalStore`
- 提醒能力基于 `@ohos.reminderAgentManager`
- Widget 基于 `FormExtensionAbility + formBindingData`
- Bundle Name：`com.chinadbo.harmonybirth`

## 说明

当前仓库已按 `.mc/CONTEXT.md` 要求生成完整文件结构。如需继续补充联系人导入、编辑联系人、深色模式或更严格的提醒权限适配，可在此基础上继续扩展。
