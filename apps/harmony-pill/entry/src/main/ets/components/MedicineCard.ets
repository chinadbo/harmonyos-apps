import { Medicine } from '../models/MedicineModel'

@Component
export struct MedicineCard {
  @Prop medicine: Medicine
  @Prop showStock: boolean = true
  onClick?: () => void
  onLongPress?: () => void

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.medicine.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (this.medicine.spec) {
            Text(this.medicine.spec)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 2 })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        if (this.showStock && this.medicine.stock > 0) {
          Text(`${this.medicine.stock}${this.medicine.unit || '片'}`)
            .fontSize(14)
            .fontColor(this.medicine.stock < 10 ? '#FF5722' : '#4CAF50')
            .backgroundColor(this.medicine.stock < 10 ? '#FFEBEE' : '#E8F5E9')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(4)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      if (this.medicine.notes) {
        Text(this.medicine.notes)
          .fontSize(12)
          .fontColor('#AAAAAA')
          .margin({ top: 4 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: '#0D000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      if (this.onClick) {
        this.onClick()
      }
    })
    .gesture(
      LongPressGesture({ duration: 500 })
        .onAction(() => {
          if (this.onLongPress) {
            this.onLongPress()
          }
        })
    )
  }
}
