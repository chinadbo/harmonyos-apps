# HarmonyOS 编码规范（必须遵守）

## 装饰器体系
- 统一使用 V1 体系：@Component + @State/@Prop/@Link/@StorageProp/@StorageLink
- 禁止使用 @ComponentV2/@ObservedV2/@Trace/@Param/@Local/@Monitor/@Computed
- 禁止在同一项目中混用 V1 和 V2 装饰器

## Import 风格
- 统一使用 @ohos.* 风格（如 `import http from '@ohos.net.http'`）
- 不使用 @kit.* 风格

## 常见陷阱（禁止踩坑）
- BasicDataSource 不是框架内置类，必须自行实现 IDataSource 接口
- fs.listFile() 返回 string[]，不是迭代器，没有 .next() 方法
- 不存在 media.fetchAVFileDescriptor，获取音频 metadata 用 media.createAVMetadataExtractor()
- @Reusable 只用于 V1 @Component，不用于 @ComponentV2
- PlayMode 是系统动画枚举，自定义播放模式枚举命名避免冲突（用 MusicPlayMode 等）
- onContinue 返回值类型是 AbilityConstant.OnContinueResult，不是 string
- getContext() 不能强转为 Ability 实例
- 不使用 eval() —— ArkTS 无此 API，表达式求值必须用调度场算法手动实现
- 温度换算非线性，不能用乘法系数，必须分支处理
- 汇率换算：使用 https://api.exchangerate-api.com/v4/latest/CNY（免费无 Key）

## 项目必备文件
- AppScope/app.json5 + resources/base/element/string.json + resources/base/media/app_icon.png（空文件占位）
- entry/src/main/module.json5
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json
- entry/src/main/resources/base/element/string.json
- entry/src/main/resources/base/element/color.json
- entry/src/main/resources/rawfile/fallback_rates.json
- build-profile.json5 + oh-package.json5
- privacy_statement.json
- README.md

## 权限最小化
- 只申请 ohos.permission.INTERNET（汇率网络请求用）
- 不申请 READ_MEDIA、CAMERA 等无关权限

## 本 App 特有规范
- 表达式求值：使用调度场算法（Shunting-Yard + RPN Stack），在 ExpressionEvaluator.ets 实现
- 单位换算：基值架构（to_SI + from_SI），温度单独函数分支
- 汇率：Preferences 缓存，超过 24h 才刷新，无网络时用 rawfile/fallback_rates.json 兜底
- RelationalStore 历史表：id/expression/result/mode/created_at，最多保留 100 条
- UI：底部 TabBar 4 Tab（标准计算器 / 科学计算器 / 单位换算 / 汇率换算）
- 颜色主题：深色背景（#1C1C1E），按键区分运算符（橙色）/数字（深灰）/功能键（中灰）
- CalcButton 用 @Builder 实现，@State 驱动按下状态缩放动画

## 任务说明
实现 HarmonyCalc — 多功能计算器 App，包含：
1. StandardCalcPage：标准四则运算 + 历史记录
2. ScientificCalcPage：科学函数 + 历史记录
3. UnitConverterPage：5 类单位换算
4. CurrencyPage：9 种货币汇率换算（网络 + 缓存 + fallback）
