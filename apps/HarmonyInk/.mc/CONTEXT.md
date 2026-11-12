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
- 本项目仅需 ohos.permission.VIBRATE

## 本项目专项规范（HarmonyInk 汉字笔顺练习）
- 严格按 architecture.md 的模块划分和页面列表实现，6 页面 + 4 组件
- 笔画数据放 rawfile/chars.json，结构见 architecture.md 数据模型章节
- 评分算法按 TraceMatcher/StrokeScorer 职责拆分：顺序/方向/覆盖度三维
- Canvas 坐标统一归一化 0-100，绘制时按画布尺寸换算
- 触控轨迹采集用 onTouch（Move 事件），PanGesture 不适合逐点采样
- RDB 建表 SQL 见 architecture.md，DbHelper 单例封装
- chars.json 需内置 100+ 常用字（一年级为主，1-10 画），每个字的 strokes.points 用折线近似标准楷体笔顺，数据可程序化生成（横平竖直/撇捺弧线采样即可）
- 所有文案中文
