import { CityModel } from '../model/CityModel';

@Component
export struct CitySearchItem {
  @Prop city: CityModel;
  @Prop onSelect: (city: CityModel) => void;
  @Prop onDelete: (city: CityModel) => void;

  build() {
    Row() {
      Column({ space: 4 }) {
        Text(this.city.name)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#F7FBFF')
        Text(`${this.city.region} ${this.city.country}`)
          .fontSize(12)
          .fontColor('#AFC8D9')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Button(this.city.isCurrentLocation ? 'Current' : 'Open')
        .height(34)
        .fontSize(13)
        .backgroundColor('#2E7DFF')
        .onClick(() => this.onSelect(this.city))

      Button('Delete')
        .height(34)
        .fontSize(13)
        .margin({ left: 8 })
        .backgroundColor('#D95D5D')
        .onClick(() => this.onDelete(this.city))
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#14FFFFFF')
    .borderRadius(20)
  }
}
