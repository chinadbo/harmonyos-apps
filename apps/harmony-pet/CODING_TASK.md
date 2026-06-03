# HarmonyPet 编码任务

请根据以下规范，完整实现 HarmonyPet — 宠物管理助手 App。

## 参考文件
- `.mc/CONTEXT.md` — 编码规范（必须遵守）
- 本文件 — 完整实现要求

## 实现要求

### 1. 工程配置文件

**AppScope/app.json5**
```json
{
  "app": {
    "bundleName": "com.chinadbo.harmonypet",
    "vendor": "chinadbo",
    "versionCode": 1,
    "versionName": "1.0.0",
    "icon": "$media:app_icon",
    "label": "$string:app_name"
  }
}
```

**build-profile.json5** — 标准 HarmonyOS NEXT API 16 配置

**oh-package.json5** — 无第三方依赖

**entry/src/main/module.json5** — 包含 EntryAbility + FeedWidgetAbility，权限声明：READ_IMAGEVIDEO

**entry/src/main/resources/base/profile/main_pages.json**：
```json
{
  "src": [
    "pages/Index",
    "pages/PetDetail",
    "pages/EditPet",
    "pages/WeightLog",
    "pages/FeedLog",
    "pages/HealthEvent",
    "pages/PhotoWall",
    "pages/ReminderSettings"
  ]
}
```

### 2. 数据模型（model/）

**Pet.ets**
```typescript
export interface Pet {
  id: number
  name: string
  species: string  // '猫' | '狗' | '鸟' | '兔' | '其他'
  breed: string
  birthDate: string  // YYYY-MM-DD
  gender: string  // '公' | '母' | '未知'
  avatarUri: string
  createdAt: number
}
```

类似定义 WeightRecord / FeedLog / HealthEvent / PetPhoto（见架构文档）

### 3. DatabaseHelper.ets

单例模式，建 5 张表（pets/weight_records/feed_logs/health_events/pet_photos），使用 2 参数 getRdbStore。

### 4. DAO 层（每个表一个 DAO）

PetDao：insert/update/delete/queryAll/queryById
WeightDao：insert/queryByPetId（最近 30 条）/queryTodayCount
FeedDao：insert/queryByPetId/queryTodayCount
HealthDao：insert/update/delete/queryByPetId/queryUpcoming（未来 30 天内到期）
PhotoDao：insert/delete/queryByPetId

### 5. 服务层

**ReminderService.ets** — reminderAgentManager 封装
- publishFeedReminder(hour, minute) → reminderId（ALARM 类型，每天循环）
- publishVaccineReminder(date, title) → reminderId（CALENDAR 类型）
- cancelReminder(reminderId)

**NotificationService.ets** — 疫苗到期通知
- sendVaccineNotification(petName, vaccineName, daysLeft)
- 附带 ActionButton：查看详情

### 6. 页面实现

**Index.ets（首页）**
- 顶部标题 "我的宠物"
- 宠物列表（ForEach + PetCard 组件）
- 空状态：图标 + "添加第一只宠物" 按钮
- 右上角 "+" 按钮跳转 EditPet
- 点击宠物卡片跳转 PetDetail

**PetCard.ets（组件）**
- 圆形头像（Image，默认猫爪图标）
- 宠物名、品种、年龄（从 birthDate 计算）
- 右侧箭头图标

**EditPet.ets**
- TextInput：名字、品种
- Select/Radio：物种选择（猫/狗/鸟/兔/其他）、性别
- DatePicker：出生日期
- 头像选取：Button 触发 PhotoViewPicker，Image 预览
- 保存/取消按钮

**PetDetail.ets**
- 顶部宠物信息卡（头像、名字、品种、年龄）
- Tabs（5个）：概览/体重/喂食/健康/相册
  - 概览：最近体重、今日喂食次数、下次提醒事项
  - 体重 Tab：跳转 WeightLog
  - 喂食 Tab：跳转 FeedLog
  - 健康 Tab：跳转 HealthEvent
  - 相册 Tab：跳转 PhotoWall

**WeightLog.ets**
- WeightChart 组件（Canvas 折线图）
- 最近记录列表
- 底部 "添加体重" 按钮（弹出 Dialog 输入体重+日期）

**WeightChart.ets（Canvas 组件）**
- @State data: WeightRecord[] 入参
- Canvas 绘制：坐标轴、网格线、折线、数据点（圆点）、X轴日期标签、Y轴体重标签
- 空数据时显示 "暂无记录" 提示

**FeedLog.ets**
- 今日喂食统计（次数、总量）
- 按日期分组的喂食记录列表
- 添加喂食记录：食物类型 Select + 数量 TextInput + 时间

**HealthEvent.ets**
- 按事件类型分类展示（疫苗/就医/驱虫/洗澡/美容）
- 时间线布局（左侧时间点，右侧内容卡）
- 即将到期（next_date 距今 ≤ 30 天）高亮显示
- 添加健康事件：Dialog 表单

**PhotoWall.ets**
- WaterFlow 瀑布流布局（2 列）
- 顶部 "添加照片" 按钮（PhotoViewPicker 选取）
- 每张图片卡：Image + 日期标签

**ReminderSettings.ets**
- 喂食提醒开关 + 时间选择（TimePicker）
- 显示当前活跃提醒列表
- 支持取消提醒

### 7. Widget

**FeedWidgetAbility.ets（FormExtensionAbility）**
- onAddForm / onUpdateForm / onRemoveForm
- 查询今日喂食次数，通过 formBindingData 传递

**widget/FeedWidget.ets（2×2 ArkTS 卡片）**
- 显示：宠物名 + 今日喂食 N 次 + 下次喂食时间
- 点击跳转 App

### 8. EntryAbility.ets
- 标准生命周期
- 启动时检查即将到期的健康事件，发送通知

### 9. privacy_statement.json
```json
{
  "privacyStatementUrl": "https://chinadbo.github.io/harmonyos-apps/privacy",
  "privacyStatementEnUrl": "https://chinadbo.github.io/harmonyos-apps/privacy-en"
}
```

### 10. README.md
包含：功能介绍、截图占位、架构说明、构建方式

## 完成标准
- 所有文件编译无语法错误
- 5 张 RDB 表正确建立
- Canvas 折线图可绘制
- Widget 2×2 卡片可运行
- 权限声明完整
- 隐私声明存在
