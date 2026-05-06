# HarmonyWeather

HarmonyWeather 是一个基于 HarmonyOS ArkTS 的天气应用示例，包含完整工程配置、页面、组件、服务层、ViewModel 和桌面 Widget。

## 功能特性

- 当前天气展示
- 小时级天气卡片
- 7 日天气预报
- 城市搜索与本地持久化
- 基于 wttr.in 的天气数据获取
- 基于 geoLocationManager 的当前位置初始化
- 基于 RDB 的城市列表持久化
- 2x2 / 4x2 桌面天气卡片

## 技术栈

- HarmonyOS ArkTS
- ArkUI V1 装饰器：`@Component @State @Prop @Link @StorageProp @StorageLink`
- `@ohos.net.http`
- `@ohos.geoLocationManager`
- `@ohos.data.relationalStore`
- `@ohos.app.form.FormExtensionAbility`
- `@ohos.app.form.formBindingData`
- `@ohos.router`

## 目录结构

```text
AppScope/
entry/
  src/main/ets/
    components/
    entryability/
    model/
    pages/
    service/
    viewmodel/
    widget/
```

## 天气接口

```text
https://wttr.in/{city}?format=j2
```

## 关键实现说明

### 天气服务

`entry/src/main/ets/service/WeatherService.ets` 中使用 `http.createHttp()` 发起请求，并在完成后调用 `httpRequest.destroy()` 释放资源。

### 定位服务

`entry/src/main/ets/service/LocationService.ets` 中先调用 `geoLocationManager.isLocationEnabled()`，再尝试获取当前位置；若不可用则回退到默认城市。

### 数据持久化

`entry/src/main/ets/service/DatabaseService.ets` 使用 RDB 保存城市列表，接口全部为 `async/await` 风格。

### Widget

- `form_config.json` 中 `supportDimensions` 为字符串数组
- `WeatherFormAbility.onAddForm` 返回 `formBindingData.createFormBindingData({...})`
- `WeatherCard.ets` 使用 `@LocalStorageProp` 绑定动态字段

## 后续可增强方向

- 接入逆地理编码，将经纬度转换为真实城市名
- 增加天气图标资源映射
- 为 Widget 添加定时更新与点击跳转
- 为搜索页接入远程城市联想

## 运行说明

1. 使用 DevEco Studio 打开工程根目录。
2. 配置签名信息后同步工程。
3. 连接 HarmonyOS 设备或模拟器运行 `entry` 模块。
4. 首次运行请授予网络和定位权限。

## 文件清单

本项目已包含用户要求的全部 31 个文件。
