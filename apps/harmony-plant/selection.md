# 今日选题：HarmonyPlant

## App 基本信息
- **App 名称：** HarmonyPlant
- **包名：** com.example.harmonyplant
- **品类标签：** 花草养护 / 植物日记 / 生活工具
- **复杂度评估：** 中大型（4-5 模块，~15 文件核心代码）

## 定位
HarmonyPlant 是一款面向养花爱好者的植物养护助手，支持添加、管理、记录自家植物，提供浇水/施肥提醒、养护日志、植物百科（离线），让养护更有规律，让植物更茁壮。

## 核心功能
1. **植物档案管理** — 添加植物（名称/品种/照片/添加日期），支持编辑删除
2. **养护计划** — 为每株植物设置浇水周期（每 N 天）、施肥周期，到期自动提醒
3. **浇水/施肥记录** — 快速记录养护动作，历史可查
4. **植物日志/日记** — 为植物写成长记录，可附照片
5. **桌面 Widget** — 显示今日待浇水植物列表，一键标记已浇水
6. **通知提醒** — reminderAgentManager 进程级提醒，App 被杀也能提醒

## 技术亮点
1. **reminderAgentManager** — 基于代理提醒（CALENDAR 类型），App 不在前台也能精准提醒
2. **FormExtensionAbility Widget** — 2×2 桌面卡片，显示今日待浇水植物
3. **PhotoAccessHelper + PhotoViewPicker** — 植物照片选择，无需额外权限
4. **RelationalStore RDB** — 植物数据 + 养护记录持久化，支持多表关联查询
5. **LazyForEach + BasicDataSource** — 植物列表高性能渲染

## 页面规划
- IndexPage（Tab 导航：植物/提醒/日志/我的）
- PlantListPage — 植物列表
- PlantDetailPage — 植物详情（基本信息 + 养护记录时间线）
- AddPlantPage — 添加/编辑植物
- CareLogPage — 养护记录（浇水/施肥快速打卡）
- DiaryPage — 植物日志列表
- AddDiaryPage — 写日志（文字+照片）
- RemindersPage — 所有提醒管理

## 品类验证（去重）
- 已用品类扫描：健康/运动记录 ✅（不同），日记/心情记录 ✅（不同），睡眠记录 ✅（不同）
- **花草养护/植物日记** 在 app-registry.md 中未出现 ✅ 通过
