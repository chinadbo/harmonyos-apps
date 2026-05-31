import { Plant } from '../model/Plant'

@Reusable
@Component
export struct PlantCard {
  @Prop plant: Plant = new Plant()
  @Prop onClick: () => void = () => {}
  @Prop onWater: () => void = () => {}

  build() {
    Row({ space: 12 }) {
      if (this.plant.photoUri.length > 0) {
        Image(this.plant.photoUri)
          .width(72)
          .height(72)
          .borderRadius(12)
          .objectFit(ImageFit.Cover)
      } else {
        Stack() {
          Text('图片')
            .fontSize(16)
            .fontColor('#4CAF50')
        }
        .width(72)
        .height(72)
        .backgroundColor('#E8F5E9')
        .borderRadius(12)
      }

      Column({ space: 6 }) {
        Text(this.plant.name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.plant.species.length > 0) {
          Text(this.plant.species)
            .fontSize(13)
            .fontColor('#666666')
        }

        Text(this.plant.getWaterStatusText())
          .fontSize(13)
          .fontColor(this.plant.isWaterDueToday() ? '#D32F2F' : '#2E7D32')

        Button(this.plant.isWaterDueToday() ? '立即浇水' : '记录浇水')
          .height(32)
          .fontSize(13)
          .backgroundColor('#4CAF50')
          .fontColor(Color.White)
          .borderRadius(16)
          .onClick(() => {
            this.onWater()
          })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .padding(16)
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: '#14000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      this.onClick()
    })
  }
}
