interface ChartItem {
  label: string
  planned: number
  taken: number
}

@Component
export struct StatsChart {
  @Prop data: ChartItem[] = []

  private getMaxValue(): number {
    let max = 1
    this.data.forEach((item) => {
      if (item.planned > max) max = item.planned
    })
    return max
  }

  build() {
    Column() {
      Row() {
        Text('服药统计')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
      }
      .width('100%')
      .padding({ bottom: 16 })

      if (this.data.length === 0) {
        Text('暂无数据')
          .fontSize(14)
          .fontColor('#999999')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(32)
      } else {
        Row() {
          ForEach(this.data, (item: ChartItem) => {
            Column() {
              Column() {
                Column()
                  .width(16)
                  .height(item.planned > 0 ? (item.taken / this.getMaxValue()) * 100 : 0)
                  .backgroundColor('#4CAF50')
                  .borderRadius({ topLeft: 4, topRight: 4 })

                if (item.planned > item.taken) {
                  Column()
                    .width(16)
                    .height(((item.planned - item.taken) / this.getMaxValue()) * 100)
                    .backgroundColor('#FFCDD2')
                    .borderRadius({ bottomLeft: 4, bottomRight: 4 })
                }
              }
              .height(120)
              .justifyContent(FlexAlign.End)

              Text(item.label)
                .fontSize(10)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}
