import type { Pet } from '../model/Pet'
import { DateUtils } from '../common/DateUtils'

@Component
export struct PetCard {
  @Prop pet: Pet
  @Prop onClick: (petId: number) => void = () => {}

  build() {
    Row() {
      if (this.pet.avatarUri) {
        Image(this.pet.avatarUri)
          .width(56)
          .height(56)
          .borderRadius(28)
          .objectFit(ImageFit.Cover)
      } else {
        Stack() {
          Text('爪')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF8A00')
        }
        .width(56)
        .height(56)
        .borderRadius(28)
        .backgroundColor('#FFF6E9')
      }
      Column({ space: 6 }) {
        Text(this.pet.name)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#222222')
        Text(`${this.pet.species} · ${this.pet.breed || '未填写品种'}`)
          .fontSize(13)
          .fontColor('#666666')
        Text(DateUtils.calculateAge(this.pet.birthDate))
          .fontSize(12)
          .fontColor('#999999')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      Text('›')
        .fontSize(24)
        .fontColor('#BBBBBB')
    }
    .padding(16)
    .borderRadius(20)
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 12, color: '#12000000', offsetX: 0, offsetY: 4 })
    .onClick(() => this.onClick(this.pet.id))
  }
}
