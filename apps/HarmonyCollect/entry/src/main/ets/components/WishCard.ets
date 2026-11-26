/**
 * WishCard.ets — 心愿卡片
 */
import { WishItem } from '../model/WishItem';
import { Format } from '../common/Format';
import {
  C_CARD, C_TEXT, C_SUB, C_LINE, C_BRAND, C_SUCCESS,
  categoryColor
} from '../common/Constants';

@Component
export struct WishCard {
  @Prop wish: WishItem;
  @Prop categoryName: string = '';
  onTap: (id: number) => void = (id: number) => {};
  onAcquire: (id: number) => void = (id: number) => {};

  private stars(): string {
    const level: number = this.wish.priority < 1 ? 1 : (this.wish.priority > 3 ? 3 : this.wish.priority);
    let out: string = '';
    for (let i = 0; i < 3; i++) {
      out += i < level ? '★' : '☆';
    }
    return out;
  }

  build() {
    Row() {
      Column()
        .width(5)
        .height('100%')
        .backgroundColor(this.wish.status === 1 ? C_SUCCESS : categoryColor(this.wish.category))

      Column() {
        Row() {
          Text(this.wish.name)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.wish.status === 1 ? C_SUB : C_TEXT)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.stars())
            .fontSize(13)
            .fontColor(C_BRAND)
        }
        .width('100%')

        Row() {
          Text(this.categoryName.length > 0 ? this.categoryName : '其他')
            .fontSize(11)
            .fontColor(categoryColor(this.wish.category))
            .backgroundColor(categoryColor(this.wish.category) + '1A')
            .padding({ left: 6, right: 6, top: 1, bottom: 1 })
            .borderRadius(6)
          Text('目标 ' + Format.money(this.wish.targetPrice))
            .fontSize(12)
            .fontColor(C_SUB)
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ top: 6 })
        .alignItems(VerticalAlign.Center)

        if (this.wish.remark.length > 0) {
          Text(Format.ellipsis(this.wish.remark, 40))
            .fontSize(11)
            .fontColor(C_SUB)
            .width('100%')
            .margin({ top: 4 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 12, top: 10, bottom: 10 })
      .onClick(() => this.onTap(this.wish.id))

      if (this.wish.status === 1) {
        Text('已入手')
          .fontSize(12)
          .fontColor(C_SUCCESS)
          .margin({ right: 12 })
      } else {
        Text('已入手')
          .fontSize(12)
          .fontColor(0xFFFFFF)
          .backgroundColor(C_SUCCESS)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(14)
          .margin({ right: 12 })
          .onClick(() => this.onAcquire(this.wish.id))
      }
    }
    .width('100%')
    .backgroundColor(C_CARD)
    .borderRadius(14)
    .border({ width: 1, color: C_LINE })
    .clip(true)
    .alignItems(VerticalAlign.Center)
  }
}
