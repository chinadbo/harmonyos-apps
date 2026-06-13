@Component
export struct NutrientPieChart {
  @Prop proteinPercent: number = 0
  @Prop carbPercent: number = 0
  @Prop fatPercent: number = 0

  @Builder
  legendRow(label: string, value: number, color: Resource) {
    Row() {
      Row()
        .width(10)
        .height(10)
        .borderRadius(5)
        .backgroundColor(color)
        .margin({ right: 8 })
      Text(label)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
      Blank()
      Text(`${value.toFixed(1)}%`)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
    }
    .width('100%')
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Column() {
          Row()
            .width(`${Math.max(this.proteinPercent, 8)}%`)
            .height(14)
            .backgroundColor($r('app.color.accent'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height(14)
      .backgroundColor('#14000000')
      .borderRadius(8)

      Row() {
        Column() {
          Row()
            .width(`${Math.max(this.carbPercent, 8)}%`)
            .height(14)
            .backgroundColor($r('app.color.primary'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height(14)
      .backgroundColor('#14000000')
      .borderRadius(8)

      Row() {
        Column() {
          Row()
            .width(`${Math.max(this.fatPercent, 8)}%`)
            .height(14)
            .backgroundColor($r('app.color.secondary'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height(14)
      .backgroundColor('#14000000')
      .borderRadius(8)

      Column({ space: 10 }) {
        this.legendRow('Protein', this.proteinPercent, $r('app.color.accent'))
        this.legendRow('Carbs', this.carbPercent, $r('app.color.primary'))
        this.legendRow('Fat', this.fatPercent, $r('app.color.secondary'))
      }
      .width('100%')
    }
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(20)
  }
}
