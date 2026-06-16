import { Gift } from '../model/Gift';

@Component
export struct GiftItem {
  @Prop gift: Gift;
  onToggle?: (gift: Gift) => void;
  onDelete?: (gift: Gift) => void;

  build() {
    Row() {
      Column({ space: 6 }) {
        Row() {
          Text(this.gift.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
          Text(this.gift.status === 'sent' ? '已送出' : '待准备')
            .fontSize(12)
            .fontColor(this.gift.status === 'sent' ? '#047857' : '#B45309')
            .backgroundColor(this.gift.status === 'sent' ? '#D1FAE5' : '#FEF3C7')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(12)
            .margin({ left: 8 })
        }
        if (this.gift.price > 0) {
          Text(`预算 ¥${this.gift.price.toFixed(2)}`)
            .fontSize(13)
            .fontColor('#6B7280')
        }
        if (this.gift.url.length > 0) {
          Text(this.gift.url)
            .fontSize(12)
            .fontColor('#2563EB')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        if (this.gift.note.length > 0) {
          Text(this.gift.note)
            .fontSize(13)
            .fontColor('#4B5563')
        }
      }
      .layoutWeight(1)
      Column({ space: 8 }) {
        Button(this.gift.status === 'sent' ? '标记待送' : '标记送出')
          .fontSize(12)
          .height(34)
          .backgroundColor('#FFEDD5')
          .fontColor('#C2410C')
          .onClick(() => {
            if (this.onToggle) {
              this.onToggle(this.gift);
            }
          })
        Button('删除')
          .fontSize(12)
          .height(34)
          .backgroundColor('#FEE2E2')
          .fontColor('#B91C1C')
          .onClick(() => {
            if (this.onDelete) {
              this.onDelete(this.gift);
            }
          })
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
  }
}
