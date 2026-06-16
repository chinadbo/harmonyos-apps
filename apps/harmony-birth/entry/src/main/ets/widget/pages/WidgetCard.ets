@Entry
@Component
struct WidgetCard {
  @State title: string = '最近生日';
  @State items: Array<{ name: string; birthday: string; countdown: string }> = [];

  aboutToAppear(): void {
    let localStorage = new LocalStorage();
    this.title = localStorage.get<string>('title') ?? '最近生日';
    this.items = localStorage.get<Array<{ name: string; birthday: string; countdown: string }>>('items') ?? [];
  }

  build() {
    Column({ space: 10 }) {
      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .fontColor('#111827')
      ForEach(this.items, (item) => {
        Row() {
          Column({ space: 2 }) {
            Text(item.name)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .width('100%')
            Text(item.birthday)
              .fontSize(12)
              .fontColor('#6B7280')
              .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Text(item.countdown)
            .fontSize(12)
            .fontColor('#C2410C')
            .backgroundColor('#FFF1ED')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(12)
        }
        .width('100%')
      }, (item) => `${item.name}-${item.birthday}`)
      if (this.items.length === 0) {
        Text('暂无生日数据')
          .fontSize(13)
          .fontColor('#6B7280')
          .width('100%')
      }
    }
    .padding(12)
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
