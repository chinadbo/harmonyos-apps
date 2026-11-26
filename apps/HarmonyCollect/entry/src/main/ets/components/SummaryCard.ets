/**
 * SummaryCard.ets — 统计概览小卡
 */
import { C_CARD, C_TEXT, C_SUB, C_LINE } from '../common/Constants';

@Component
export struct SummaryCard {
  @Prop label: string = '';
  @Prop value: string = '';
  @Prop hint: string = '';
  @Prop accent: string = '#B0743B';

  build() {
    Column() {
      Row() {
        Column()
          .width(6)
          .height(14)
          .borderRadius(3)
          .backgroundColor(this.accent)
        Text(this.label)
          .fontSize(12)
          .fontColor(C_SUB)
          .margin({ left: 6 })
      }
      .alignItems(VerticalAlign.Center)

      Text(this.value)
        .fontSize(19)
        .fontWeight(FontWeight.Bold)
        .fontColor(C_TEXT)
        .margin({ top: 8 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.hint.length > 0) {
        Text(this.hint)
          .fontSize(11)
          .fontColor(this.accent)
          .margin({ top: 4 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .padding(14)
    .backgroundColor(C_CARD)
    .borderRadius(16)
    .border({ width: 1, color: C_LINE })
  }
}
