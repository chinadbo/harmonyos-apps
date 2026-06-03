# HarmonyPet

HarmonyPet 是一个基于 HarmonyOS NEXT ArkTS 的宠物管理助手，支持宠物档案、体重记录、喂食日志、健康事件、照片墙、提醒设置和桌面卡片。

## 功能介绍
- 宠物档案管理：新增、编辑、查看宠物信息
- 体重记录：折线图展示近期体重变化
- 喂食日志：记录每日喂食次数和数量
- 健康事件：管理疫苗、就医、驱虫、洗澡、美容等事件
- 照片墙：为每只宠物维护照片瀑布流相册
- 提醒服务：喂食提醒与疫苗到期通知
- Feed Widget：2×2 桌面卡片展示今日喂食情况

## 截图占位
- 首页截图：`docs/screenshots/index.png`
- 宠物详情截图：`docs/screenshots/detail.png`
- 体重图表截图：`docs/screenshots/weight-chart.png`
- 桌面卡片截图：`docs/screenshots/widget.png`

## 架构说明
- `entry/src/main/ets/model`：数据模型
- `entry/src/main/ets/database`：RDB 数据库与 DAO
- `entry/src/main/ets/service`：提醒与通知服务
- `entry/src/main/ets/components`：复用组件
- `entry/src/main/ets/pages`：页面实现
- `entry/src/main/ets/widget`：桌面卡片与 FormExtensionAbility
- `entry/src/main/ets/entryability`：应用入口 Ability

## 构建方式
1. 使用 DevEco Studio 打开工程目录。
2. 确保 SDK 为 HarmonyOS NEXT API 16。
3. 同步工程配置并执行编译。
4. 安装到真机或模拟器后，授予图片读取权限以使用头像与照片墙功能。
