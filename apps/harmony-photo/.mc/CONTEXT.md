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
- effectKit.createEffect() 接受 PixelMap，返回 Filter 对象（不是 VisualEffect）
- Filter.getEffectPixelMap() 是异步的，必须 await
- PhotoViewPicker.select() 返回 PhotoSelectResult，结果在 .photoUris 数组中
- image.createImageSource(fd) 中 fd 必须是 number（文件描述符），不是路径字符串
- fileIo.open() 返回 File 对象，fd 在 .fd 属性上
- WaterFlow 必须配合 LazyForEach + IDataSource 使用，不支持 ForEach

## 项目必备文件
- AppScope/app.json5 + resources/base/element/string.json + resources/base/media/（占位图）
- entry/src/main/module.json5
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json
- entry/src/main/resources/base/element/string.json
- entry/src/main/resources/base/element/color.json
- build-profile.json5（根 + entry/）
- oh-package.json5（根 + entry/）
- privacy_statement.json
- README.md

## 权限最小化
- 只申请实际用到的权限
- 使用 PhotoViewPicker 无需申请 READ_IMAGEVIDEO（用户主动选取）
- 批量读取相册才需要 ohos.permission.READ_IMAGEVIDEO

## 本项目技术要点（HarmonyPhoto 专属）
- 相册浏览：使用 WaterFlow + LazyForEach + IDataSource，两列瀑布流
- 月份分组：用 List + ListItemGroup + sticky(.sticky(StickyStyle.Header))
- 实时滤镜：effectKit.createEffect(pixelMap) → .brightness/.contrast/.saturate/.blur → getEffectPixelMap()
- 图片获取：fileIo.open(uri) → image.createImageSource(fd.fd) → createPixelMap()
- 保存：使用 SaveButton 组件（无需权限）
- RDB 收藏：relationalStore.getRdbStore() + 简单 CRUD
- 裁剪：Canvas 组件 + 手势（PanGestureOptions + PinchGestureOptions）
- 全屏预览：Swiper + Image（scaleType: ImageFit.Contain）

## 架构文件（参考）
见同目录的 architecture.md（相对路径：../../architecture.md）
