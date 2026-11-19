import { LoanCalculator } from '../model/LoanCalculator';

@Component
export default struct ResultCard {
  @Prop monthlyFen: number = 0;
  @Prop totalInterestFen: number = 0;
  @Prop totalPayFen: number = 0;
  @Prop totalPrincipalFen: number = 0;
  @Prop modeLabel: string = '';
  @Prop rateLabel: string = '';

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('每月月供')
          .fontSize(14)
          .fontColor('#6B7280')
        Blank()
        if (this.modeLabel.length > 0) {
          Text(this.modeLabel)
            .fontSize(11)
            .fontColor('#2B6CF6')
            .backgroundColor('#EAF0FF')
            .borderRadius(8)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
        }
      }
      .width('100%')

      Row({ space: 4 }) {
        Text('¥')
          .fontSize(20)
          .fontColor('#1D4ED8')
          .margin({ top: 8 })
        Text(LoanCalculator.fenToYuan(this.monthlyFen))
          .fontSize(34)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1D4ED8')
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      if (this.rateLabel.length > 0) {
        Text(this.rateLabel)
          .fontSize(12)
          .fontColor('#9CA3AF')
          .width('100%')
      }

      Divider()
        .color('#EEF0F5')

      Row() {
        this.statItem('贷款本金', LoanCalculator.fenToYuanNoDecimal(this.totalPrincipalFen))
        this.statItem('支付利息', LoanCalculator.fenToYuanNoDecimal(this.totalInterestFen))
        this.statItem('还款总额', LoanCalculator.fenToYuanNoDecimal(this.totalPayFen))
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 12, color: '#14000000', offsetX: 0, offsetY: 4 })
  }

  @Builder
  statItem(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(11)
        .fontColor('#9CA3AF')
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111827')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }
}
