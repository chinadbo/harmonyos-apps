# HarmonySpeed

> 专为 HarmonyOS NEXT 设计的网速测试与网络诊断工具

## 功能特性

- **下载速度测试** — HTTP GET 下载 5MB 文件，精确计算下行带宽（Mbps）
- **上传速度测试** — HTTP POST 发送 2MB 随机数据，计算上行带宽
- **延迟检测** — 5 次 Ping 取平均值，计算 Ping(ms) 和抖动(ms)
- **网络信息** — 实时显示网络类型（WiFi/4G/5G）、本机 IP、WiFi 名称
- **历史记录** — RDB 持久化保存最近 100 条测速结果，折线图趋势分析
- **桌面 Widget** — 2×2 卡片展示最近一次测速结果（下行/上行/Ping）
- **仪表盘 UI** — Canvas 绘制半圆形仪表，颜色分区（绿/黄/红）

## 架构

```
entry/src/main/ets/
├── entryability/      # UIAbility 入口
├── entryformability/  # FormExtensionAbility（Widget）
├── pages/             # Navigation 根页面
├── views/             # HomeView / HistoryView / SettingsView
├── components/        # SpeedometerCanvas / LineChartCanvas / NetworkInfoCard / SpeedResultCard
├── service/           # SpeedTestService / NetworkService
├── database/          # SpeedDatabase (RDB)
├── model/             # SpeedRecord / SpeedTestPhase
└── widget/            # WidgetCard (Form 卡片)
```

## 技术栈

| 技术 | 用途 |
|------|------|
| `@ohos.net.http` | HTTP 测速（下载/上传/Ping） |
| `@ohos.net.connection` | 获取网络类型和连接信息 |
| `@ohos.wifiManager` | 获取 WiFi SSID 和信号强度 |
| `CanvasRenderingContext2D` | 仪表盘弧形动画和历史折线图 |
| `@ohos.data.relationalStore` | 历史记录 RDB 持久化 |
| `Form Kit` | 2×2 桌面卡片 Widget |

## 测速服务器

- 下载：`https://speed.cloudflare.com/__down?bytes=5000000`
- 上传：`https://speed.cloudflare.com/__up`
- Ping：`https://1.1.1.1/cdn-cgi/trace`

## 构建方式

1. 要求：DevEco Studio 4.x，HarmonyOS SDK API 12
2. 打开项目根目录
3. 配置签名（Build → Generate Key and CSR）
4. 点击 Run 或 Build HAP

## 权限声明

| 权限 | 用途 |
|------|------|
| `ohos.permission.INTERNET` | 网络测速访问 |
| `ohos.permission.GET_WIFI_INFO` | 显示 WiFi 信息 |
| `ohos.permission.GET_NETWORK_INFO` | 获取网络类型 |

## 注意事项

- 测速精度受当前网络状况和 Cloudflare 服务器响应影响
- Widget 刷新数据需在 App 内完成测速后自动更新
- 历史记录最多保留 100 条，超出自动删除最早记录
