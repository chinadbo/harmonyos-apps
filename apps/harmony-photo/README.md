# HarmonyPhoto

> 鸿蒙原生相册管理与照片编辑 App

## 功能特性

- 📸 **相册浏览**：WaterFlow 两列瀑布流，月份智能分组，sticky header
- 🔍 **全屏预览**：Swiper 左右滑动，双击收藏，下滑关闭
- 🎨 **实时滤镜**：6种预设滤镜（清晨/暖调/冷淡/复古/黑白/原图）
- 🎛️ **精细调节**：亮度/对比度/饱和度/模糊 四维独立调节
- ❤️ **收藏管理**：RDB 本地存储，收藏 Tab 独立展示
- 💾 **保存到相册**：PhotoAccessHelper 创建新资产保存

## 技术架构

| 模块 | 技术实现 |
|------|---------|
| 相册读取 | `@ohos.file.photoAccessHelper` PhotoViewPicker |
| 瀑布流布局 | WaterFlow + LazyForEach + IDataSource |
| 月份分组 | List + ListItemGroup + sticky header |
| 实时滤镜 | `@ohos.effectKit` Filter 链（brightness/contrast/saturate/blur）|
| 本地收藏 | `@ohos.data.relationalStore` RDB |
| 装饰器体系 | V1（@Component/@State/@Prop/@Link）|

## 项目结构

```
harmony-photo/
├── AppScope/                    # 应用级配置
├── entry/src/main/
│   ├── ets/
│   │   ├── pages/Index.ets      # TabBar 主容器
│   │   ├── views/               # 页面级组件
│   │   │   ├── GalleryView.ets  # 相册浏览
│   │   │   ├── PhotoPreview.ets # 全屏预览
│   │   │   ├── EditView.ets     # 编辑页
│   │   │   └── FavoritesView.ets# 收藏页
│   │   ├── components/          # 可复用组件
│   │   ├── model/               # 数据模型
│   │   ├── service/             # 业务服务
│   │   └── utils/               # 工具函数
│   └── resources/
├── build-profile.json5
└── oh-package.json5
```

## 构建方式

1. 使用 DevEco Studio 4.1+ 打开项目
2. 配置签名（Build → Generate Key and CSR）
3. 连接真机（需要 API 12+ 设备）
4. Run 'entry'

## API 要求

- HarmonyOS API Level 12+
- 权限：`ohos.permission.READ_IMAGEVIDEO`

## 开发者

chinadbo - HarmonyOS Apps Collection
