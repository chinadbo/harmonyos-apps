import router from '@ohos.router';

@Entry
@Component
struct AboutPage {
  @StorageLink('isDarkMode') isDarkMode: boolean = false;

  build() {
    Column({ space: 16 }) {
      Row() {
        Button('返回')
          .backgroundColor(this.isDarkMode ? '#FF303B48' : '#FFE7ECF3')
          .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')
          .onClick(() => {
            router.back();
          })
        Blank()
      }
      .width('100%')

      Text('关于 HarmonyMind')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')

      Text('HarmonyMind 是一款本地运行的脑图与头脑风暴工具，支持快速创建主题、拆分子节点、颜色标记以及画布自由浏览。')
        .fontSize(16)
        .fontColor(this.isDarkMode ? '#FFD5DFEA' : '#FF4D5A68')
        .lineHeight(24)

      Text('版本：1.0.0')
        .fontSize(16)
        .fontColor(this.isDarkMode ? '#FFD5DFEA' : '#FF4D5A68')

      Text('隐私说明：应用不会联网，不采集个人信息，所有脑图内容和主题设置仅保存在当前设备本地。')
        .fontSize(16)
        .fontColor(this.isDarkMode ? '#FFD5DFEA' : '#FF4D5A68')
        .lineHeight(24)

      Blank()
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDarkMode ? '#FF14181F' : '#FFF7F8FC')
    .alignItems(HorizontalAlign.Start)
  }
}
