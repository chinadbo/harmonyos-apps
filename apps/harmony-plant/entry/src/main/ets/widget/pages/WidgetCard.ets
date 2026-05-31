@Component
export struct WidgetCard {
  @Prop title: string = '今日浇水'
  @Prop subtitle: string = '待处理植物'
  @Prop plants: string[] = []

  build() {
    Column({ space: 10 }) {
      Row() {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text(this.subtitle)
          .fontSize(12)
          .fontColor('#666666')
      }
      .width('100%')

      if (this.plants.length === 0) {
        Column() {
          Text('今天没有待浇水植物')
            .fontSize(15)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Column({ space: 8 }) {
          ForEach(this.plants.slice(0, 3), (plantName: string) => {
            Row() {
              Text('•')
                .fontColor('#4CAF50')
              Text(plantName)
                .fontSize(15)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ left: 8 })
            }
            .width('100%')
          }, (plantName: string) => plantName)
        }
        .width('100%')
      }

      Button('打开应用')
        .width('100%')
        .height(34)
        .backgroundColor('#4CAF50')
        .fontColor(Color.White)
        .borderRadius(17)
        .onClick(() => {
          postCardAction(this, JSON.stringify({ action: 'openApp' }))
        })
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
