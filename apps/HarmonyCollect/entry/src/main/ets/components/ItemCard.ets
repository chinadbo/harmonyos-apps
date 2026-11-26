/**
 * ItemCard.ets — 藏品卡片（网格 / 列表两种形态）
 */
import { CollectItem } from '../model/CollectItem';
import { ImageStore } from '../common/ImageStore';
import { Format } from '../common/Format';
import {
  C_CARD, C_TEXT, C_SUB, C_LINE, C_BRAND, C_DANGER, C_SUCCESS,
  categoryColor, conditionColor
} from '../common/Constants';

@Component
export struct ItemCard {
  @Prop item: CollectItem;
  @Prop categoryName: string = '';
  @Prop categoryIcon: string = '';
  @Prop mode: string = 'grid';
  onTap: (id: number) => void = (id: number) => {};

  private gainColor(): string {
    const gain: number = this.item.estValue - this.item.acquirePrice;
    if (gain > 0) {
      return C_SUCCESS;
    }
    if (gain < 0) {
      return C_DANGER;
    }
    return C_SUB;
  }

  private gainText(): string {
    if (this.item.acquirePrice <= 0) {
      return '';
    }
    const gain: number = this.item.estValue - this.item.acquirePrice;
    const sign: string = gain > 0 ? '+' : (gain < 0 ? '-' : '');
    return sign + Format.moneyShort(gain);
  }

  @Builder
  Placeholder(size: number) {
    Stack() {
      Column()
        .width(size)
        .height(size)
        .backgroundColor(categoryColor(this.item.category) + '22')
      Text(this.categoryIcon.length > 0 ? this.categoryIcon : '◈')
        .fontSize(size * 0.34)
        .fontColor(categoryColor(this.item.category))
    }
    .width(size)
    .height(size)
  }

  @Builder
  GridCard() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        if (this.item.imageUri.length > 0) {
          Image(ImageStore.toDisplaySrc(this.item.imageUri))
            .width('100%')
            .height(128)
            .objectFit(ImageFit.Cover)
            .backgroundColor(C_LINE)
        } else {
          Stack() {
            Column()
              .width('100%')
              .height(128)
              .backgroundColor(categoryColor(this.item.category) + '1A')
            Text(this.categoryIcon.length > 0 ? this.categoryIcon : '◈')
              .fontSize(42)
              .fontColor(categoryColor(this.item.category) + '99')
          }
          .width('100%')
          .height(128)
        }

        if (this.item.acquirePrice > 0) {
          Text(this.gainText())
            .fontSize(11)
            .fontColor(0xFFFFFF)
            .backgroundColor(this.gainColor())
            .padding({ left: 7, right: 7, top: 2, bottom: 2 })
            .borderRadius(8)
            .margin(8)
        }
      }
      .width('100%')

      Column() {
        Text(this.item.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(C_TEXT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row() {
          Text(this.categoryName.length > 0 ? this.categoryName : '其他')
            .fontSize(11)
            .fontColor(categoryColor(this.item.category))
          Text(this.item.condition)
            .fontSize(10)
            .fontColor(conditionColor(this.item.condition))
            .backgroundColor(conditionColor(this.item.condition) + '1A')
            .padding({ left: 6, right: 6, top: 1, bottom: 1 })
            .borderRadius(6)
            .margin({ left: 6 })
        }
        .width('100%')
        .margin({ top: 6 })
        .alignItems(VerticalAlign.Center)

        Text(Format.money(this.item.estValue))
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(C_BRAND)
          .width('100%')
          .margin({ top: 6 })
      }
      .alignItems(HorizontalAlign.Start)
      .padding(10)
      .width('100%')
    }
    .width('100%')
    .backgroundColor(C_CARD)
    .borderRadius(16)
    .border({ width: 1, color: C_LINE })
    .clip(true)
    .onClick(() => this.onTap(this.item.id))
  }

  @Builder
  ListCard() {
    Row() {
      if (this.item.imageUri.length > 0) {
        Image(ImageStore.toDisplaySrc(this.item.imageUri))
          .width(76)
          .height(76)
          .borderRadius(12)
          .objectFit(ImageFit.Cover)
          .backgroundColor(C_LINE)
      } else {
        Stack() {
          Column()
            .width(76)
            .height(76)
            .borderRadius(12)
            .backgroundColor(categoryColor(this.item.category) + '1A')
          Text(this.categoryIcon.length > 0 ? this.categoryIcon : '◈')
            .fontSize(30)
            .fontColor(categoryColor(this.item.category) + '99')
        }
      }

      Column() {
        Row() {
          Text(this.item.name)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(C_TEXT)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.item.condition)
            .fontSize(10)
            .fontColor(conditionColor(this.item.condition))
            .backgroundColor(conditionColor(this.item.condition) + '1A')
            .padding({ left: 6, right: 6, top: 1, bottom: 1 })
            .borderRadius(6)
        }
        .width('100%')

        Row() {
          Text((this.categoryName.length > 0 ? this.categoryName : '其他') + ' · ' +
            (this.item.acquireDate.length > 0 ? this.item.acquireDate : '未记录日期'))
            .fontSize(11)
            .fontColor(C_SUB)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .margin({ top: 4 })

        Row() {
          Text(Format.money(this.item.estValue))
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(C_BRAND)
          if (this.item.acquirePrice > 0) {
            Text(this.gainText())
              .fontSize(11)
              .fontColor(this.gainColor())
              .margin({ left: 8 })
          }
          Blank()
          if (this.item.serial.length > 0) {
            Text(this.item.serial)
              .fontSize(10)
              .fontColor(C_SUB)
              .maxLines(1)
              .constraintSize({ maxWidth: 90 })
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('100%')
        .margin({ top: 6 })
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(C_CARD)
    .borderRadius(16)
    .border({ width: 1, color: C_LINE })
    .onClick(() => this.onTap(this.item.id))
  }

  build() {
    if (this.mode === 'list') {
      this.ListCard()
    } else {
      this.GridCard()
    }
  }
}
