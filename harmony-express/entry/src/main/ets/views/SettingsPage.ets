@NavDestination
@Component
export struct SettingsPage {
  @Consume('navStack') navStack: NavPathStack;
  @StorageLink('notificationsEnabled') notificationsEnabled: boolean = true;

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Text('设置')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)

        Row() {
          Text('状态变更通知')
            .fontSize(16)
            .fontColor('#101828')
            .layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.notificationsEnabled })
            .onChange((value: boolean) => {
              this.notificationsEnabled = value;
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(20)

        Column({ space: 8 }) {
          Text('关于应用')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Start)
          Text('Harmony Express 使用 relationalStore 本地保存快递数据，并优先读取 rawfile/mock_data.json 作为查询结果。')
            .fontSize(14)
            .fontColor('#475467')
            .width('100%')
            .textAlign(TextAlign.Start)
          Text('当单号未命中预置数据时，应用会自动生成一组运输中的演示轨迹，便于调试页面与通知流程。')
            .fontSize(14)
            .fontColor('#475467')
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(20)
      }
      .padding(16)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F4F7')
  }
}
