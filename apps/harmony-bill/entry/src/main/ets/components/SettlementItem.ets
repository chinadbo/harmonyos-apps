import { SettlementDetail } from '../model/Settlement';
import { FormatUtils } from '../utils/FormatUtils';
import { ColorUtils } from '../utils/ColorUtils';

@Component
export struct SettlementItem {
  @Prop settlement: SettlementDetail = {
    id: 0,
    groupId: 0,
    fromMemberId: 0,
    toMemberId: 0,
    amount: 0,
    isPaid: 0,
    paidAt: 0,
    fromMemberName: '',
    fromColorIndex: 0,
    toMemberName: '',
    toColorIndex: 0
  };

  build() {
    Column({ space: 12 }) {
      Row() {
        this.buildMember(this.settlement.fromMemberName, this.settlement.fromColorIndex)
        Text('→')
          .fontSize(20)
          .fontColor($r('app.color.text_secondary'))
        this.buildMember(this.settlement.toMemberName, this.settlement.toColorIndex)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Row() {
        Text(FormatUtils.formatCurrency(this.settlement.amount))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.brand_color'))
        Text(this.settlement.isPaid === 1 ? '已还款' : '待还款')
          .fontSize(12)
          .fontColor(this.settlement.isPaid === 1 ? $r('app.color.success_color') : $r('app.color.warning_color'))
          .backgroundColor(this.settlement.isPaid === 1 ? '#FFE8FFF4' : '#FFFFF7E6')
          .borderRadius(12)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.surface_color'))
    .borderRadius(18)
  }

  @Builder
  private buildMember(name: string, colorIndex: number) {
    Row({ space: 8 }) {
      Text(ColorUtils.getInitial(name))
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFFFF')
        .width(30)
        .height(30)
        .textAlign(TextAlign.Center)
        .backgroundColor(ColorUtils.getColor(colorIndex))
        .borderRadius(15)
      Text(name)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
    }
  }
}
