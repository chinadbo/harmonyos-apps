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
- relationalStore.getRdbStore 是异步操作，必须 await
- RdbPredicates 参数是表名字符串，不是对象
- insert/update/delete/query 都是异步方法，需要 await 或 .then()

## 项目必备文件
- AppScope/app.json5 + resources/base/element/string.json + resources/base/media/app_icon.png
- entry/src/main/module.json5
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json
- entry/src/main/resources/base/element/string.json
- entry/src/main/resources/base/element/color.json
- build-profile.json5（根目录）
- entry/build-profile.json5
- oh-package.json5（根目录）
- privacy_statement.json
- README.md

## 权限最小化
- 本项目无需任何权限（纯本地 RDB 存储）
- module.json5 的 requestPermissions 为空数组 []

## 本项目特定规范

### 金额处理
- 所有金额以"分"为单位存储（整数），避免浮点精度问题
- 显示时除以 100 转换为元：`(amount / 100).toFixed(2)`
- 输入时乘以 100：`Math.round(parseFloat(input) * 100)`

### RDB 操作
- DatabaseHelper 使用单例模式，懒初始化
- 所有 DAO 操作封装为 async 函数，返回 Promise
- 使用 relationalStore.RdbPredicates 构建查询条件

### 数据模型
- Group: id, name, scene(travel/dinner/rent/other), createdAt, isSettled
- Member: id, groupId, name, colorIndex
- Bill: id, groupId, title, amount(分), payerId, category, splitType(equal/custom), createdAt, note
- BillSplit: id, billId, memberId, amount(分)
- Settlement: id, groupId, fromMemberId, toMemberId, amount(分), isPaid, paidAt

### 成员颜色
colorIndex 0-7 对应：#FF6B6B, #4ECDC4, #45B7D1, #96CEB4, #FFEAA7, #DDA0DD, #98D8C8, #F7DC6F

### 结算算法
贪心最优路径：计算净余额 → 正为债主，负为债务人 → 贪心配对最小化转账次数

### 页面路由
使用 router.pushUrl({ url: 'pages/XxxPage', params: { ... } })
接收参数：router.getParams() as XxxParams

## 架构文件参考
参见 ~/.openclaw/harmony-daily-app/today/architecture.md
