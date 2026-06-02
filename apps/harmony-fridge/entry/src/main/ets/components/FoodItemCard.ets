import { FoodItem } from '../model/FoodItem';
import { DateUtils } from '../common/DateUtils';

@Component
export struct FoodItemCard {
  @Prop item: FoodItem = FoodItem.createEmpty();
  @Prop onEdit: (item: FoodItem) => void = () => {};
  @Prop onDelete: (item: FoodItem) => void = () => {};
  @Prop onAddToShopping: (item: FoodItem) => void = () => {};

  build() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.item.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#20331E')
          Text(`${this.item.quantity}${this.item.unit} · ${this.item.category} · ${this.item.storageArea}`)
            .fontSize(13)
            .fontColor('#637760')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(DateUtils.expiryText(this.item.expiryDate))
          .fontSize(12)
          .fontColor(DateUtils.expiryColor(this.item.expiryDate))
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#F6FAF5')
          .borderRadius(14)
      }

      Text(`到期日：${DateUtils.formatDate(this.item.expiryDate)}`)
        .fontSize(13)
        .fontColor('#51684E')

      if (this.item.note.length > 0) {
        Text(this.item.note)
          .fontSize(12)
          .fontColor('#70836D')
      }

      Row({ space: 12 }) {
        Button('加入购物清单')
          .layoutWeight(1)
          .backgroundColor('#E7F3E5')
          .fontColor('#2B4D2A')
          .onClick(() => {
            this.onAddToShopping(this.item);
          })
        Button('编辑')
          .type(ButtonType.Normal)
          .backgroundColor('#5D8C59')
          .onClick(() => {
            this.onEdit(this.item);
          })
        Button('删除')
          .type(ButtonType.Capsule)
          .backgroundColor('#F4D9DE')
          .fontColor('#A34053')
          .onClick(() => {
            this.onDelete(this.item);
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
  }
}
