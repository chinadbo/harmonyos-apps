import { Deposit } from '../model/Deposit'

@Component
export struct DepositItem {
  @Prop deposit: Deposit

  private formatCurrency(amountInCent: number): string {
    return `¥${(amountInCent / 100).toFixed(2)}`
  }

  build() {
    Row({ space: 12 }) {
      Column() {
        Text(this.deposit.depositDate)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F1F1F')
        Text(this.deposit.note || '未填写备注')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(`+${this.formatCurrency(this.deposit.amount)}`)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#20A162')
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 14, bottom: 14 })
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .border({ width: 1, color: '#EEF2F8' })
  }
}
