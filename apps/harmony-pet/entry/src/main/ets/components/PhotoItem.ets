import type { PetPhoto } from '../model/PetPhoto'
import { DateUtils } from '../common/DateUtils'

@Component
export struct PhotoItem {
  @Prop item: PetPhoto
  @Prop onDelete: (id: number) => void = () => {}

  build() {
    Column({ space: 8 }) {
      Image(this.item.photoUri)
        .width('100%')
        .height(160)
        .objectFit(ImageFit.Cover)
        .borderRadius(18)
      Row() {
        Text(DateUtils.formatDisplayDate(this.item.shotDate))
          .fontSize(12)
          .fontColor('#666666')
          .layoutWeight(1)
        Button('删除')
          .type(ButtonType.Capsule)
          .fontSize(11)
          .backgroundColor('#FFF0F0')
          .fontColor('#D9363E')
          .onClick(() => this.onDelete(this.item.id))
      }
    }
    .padding(10)
    .borderRadius(20)
    .backgroundColor('#FFFFFF')
  }
}
