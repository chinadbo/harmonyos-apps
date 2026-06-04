# HarmonyOS 编码规范（必须遵守）

## 装饰器体系
- 统一使用 V1 体系：@Component + @State/@Prop/@Link/@StorageProp/@StorageLink
- 禁止使用 @ComponentV2/@ObservedV2/@Trace/@Param/@Local/@Monitor/@Computed
- 禁止在同一项目中混用 V1 和 V2 装饰器

## Import 风格
- 统一使用 @ohos.* 风格（如 `import relationalStore from '@ohos.data.relationalStore'`）
- 不使用 @kit.* 风格
- **NavPathStack 是框架内置类型，无需任何 import，直接使用**

## 常见陷阱（禁止踩坑）
- BasicDataSource 不是框架内置类，必须自行实现 IDataSource 接口
- fs.listFile() 返回 string[]，不是迭代器，没有 .next() 方法
- @Reusable 只用于 V1 @Component，不用于 @ComponentV2
- PlayMode 是系统动画枚举，自定义枚举命名避免冲突
- onContinue 返回值类型是 AbilityConstant.OnContinueResult，不是 string
- getContext() 不能强转为 Ability 实例
- **PhotoViewPicker 不传 context**：`new photoAccessHelper.PhotoViewPicker()` 无参数
- **Canvas 必须先 new RenderingContextSettings(true) 再 new CanvasRenderingContext2D(settings)**
- **Widget FormExtensionAbility 必须同时实现 onCreate 和 onNewWant，否则后台点击跳转失效**
- **NavPathStack 无需 import，禁止写 `import { NavPathStack } from '@kit.ArkUI'`**
- 费用金额存储单位为"分"（整数），显示时除以 100 转元

## 本项目：HarmonyCar 架构概要

### 核心功能
1. 车辆档案管理（多车支持）
2. 保养记录（油/轮胎/刹车/年检/保险/洗车/其他，含费用）
3. 到期提醒（reminderAgentManager，日期型）
4. 费用统计图表（Canvas：柱状图+饼图+折线图）
5. Widget 桌面卡片（2×2 和 2×4）

### 数据库表
- vehicles（id/plateNumber/brand/model/purchaseDate/mileage/vin/insuranceExpiry/inspectionExpiry/color/isDefault/createdAt）
- maintenance_records（id/vehicleId/type/date/mileage/cost/shop/note/nextDate/nextMileage/photos/createdAt）
- reminders（id/vehicleId/reminderId/type/title/content/triggerDate/targetMileage/isActive/createdAt）

### 路由结构（NavPathStack，框架内置无需 import）
- Index.ets → Navigation 容器
- 页面：MainPage / CarListPage / CarEditPage / RecordListPage / RecordEditPage / StatsPage / RemindersPage

### 权限
- ohos.permission.PUBLISH_AGENT_REMINDER（代理提醒）
- ohos.permission.READ_IMAGEVIDEO（读取相册）
- ohos.permission.WRITE_IMAGEVIDEO（保存照片）

## 项目必备文件
- AppScope/app.json5 + AppScope/resources/base/element/string.json
- entry/src/main/module.json5
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json
- entry/src/main/resources/base/element/string.json
- build-profile.json5 + oh-package.json5
- privacy_statement.json（隐私声明，appId 填 com.chinadbo.harmonycar，privacyUrl 填真实URL）
- README.md（功能说明 + 架构 + 构建方式）

## 权限最小化
- 只申请实际用到的权限
- READ_MEDIA 范围太大，用 READ_IMAGEVIDEO 等细分权限
