# HarmonyExplore

HarmonyExplore 是一个基于 HarmonyOS NEXT 的城市探索/景点打卡应用。用户可以新增想去的地点、到达后立即打卡、记录心情与天气、附加照片，并在累计探索过程中解锁成就徽章与查看探索统计。

## 功能特性
- 探索页：展示景点列表与基于 Canvas 的打卡密度格
- 打卡页：按日期分组查看时间线
- 成就页：根据本地成就配置解锁徽章并发送本地通知
- 统计页：展示总打卡数、覆盖城市数与最近 7 天柱状图
- 添加景点：支持填写景点信息、逆地理编码补全城市、系统 PhotoViewPicker 选择照片并立即打卡

## 项目结构
- `AppScope/`：应用级配置与资源
- `entry/src/main/ets/entryability`：UIAbility 入口
- `entry/src/main/pages`：首页容器
- `entry/src/main/ets/model`：数据模型
- `entry/src/main/ets/service`：数据库、位置、成就、通知服务
- `entry/src/main/ets/views`：页面视图
- `entry/src/main/ets/components`：可复用组件
- `entry/src/main/resources/rawfile/achievements.json`：成就配置

## 技术实现
- ArkUI V1 装饰器体系：`@Component` + `@State/@Prop/@Link/@StorageLink`
- 路由：`Navigation + NavPathStack`
- 数据：`@ohos.data.relationalStore`，三张表 `spots / check_ins / photos`
- 位置：`@ohos.geoLocationManager` 逆地理编码
- 通知：`@ohos.notificationManager`
- 图表：Canvas 2D + `RenderingContextSettings(true)`

## 构建方式
1. 使用 DevEco Studio 打开项目根目录。
2. 确认 SDK API 16 可用。
3. 同步 `oh-package.json5` 与模块配置。
4. 选择 `entry` 模块，在 HarmonyOS NEXT 真机或模拟器上运行。

## 隐私说明
- 位置信息仅用于解析景点所在城市与本地统计。
- 照片通过系统 Picker 选择，不申请媒体库读取权限。
- 数据默认保存在本地数据库 `harmonyexplore.db`。
