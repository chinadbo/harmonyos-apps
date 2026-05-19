# HarmonyCalc

HarmonyCalc 是一个基于 HarmonyOS ArkTS 的多功能计算器应用，包含标准计算、科学计算、单位换算和汇率换算四个模块。

## 功能

- 标准计算器：支持四则运算、括号与历史记录
- 科学计算器：支持 sin / cos / tan / log / ln / sqrt / abs / factorial
- 单位换算：支持长度、重量、温度、面积、速度五类单位
- 汇率换算：支持 CNY / USD / EUR / JPY / GBP / KRW / HKD / SGD / AUD，具备网络刷新、24h 缓存与 fallback 兜底

## 技术约束

- 全量使用 V1 装饰器：`@Component`、`@State`、`@Prop`、`@Link`
- 统一使用 `@ohos.*` 导入风格
- 表达式求值使用调度场算法与 RPN 栈，不使用 `eval()`
- 历史记录使用 `@ohos.data.relationalStore`
- 汇率缓存使用 `@ohos.data.preferences`
- 深色主题：背景 `#1C1C1E`，数字键 `#2C2C2E`，运算符键 `#FF9F0A`，功能键 `#3A3A3C`

## 目录

- `AppScope/`：应用级配置与资源
- `entry/src/main/ets/engine/`：表达式求值与单位换算引擎
- `entry/src/main/ets/data/`：本地数据库与偏好缓存
- `entry/src/main/ets/network/`：汇率服务
- `entry/src/main/ets/components/`：复用 UI 组件
- `entry/src/main/ets/calculator/`：四个业务页面
- `entry/src/main/ets/pages/Index.ets`：底部 4 Tab 容器页
