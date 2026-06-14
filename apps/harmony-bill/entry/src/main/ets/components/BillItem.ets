import { BillWithPayer } from '../model/Bill';
import { FormatUtils } from '../utils/FormatUtils';

@Component
export struct BillItem {
  @Prop clickable: boolean = false;
  @Prop bill: BillWithPayer = {
    id: 0,
    groupId: 0,
    title: '',
    amount: 0,
    payerId: 0,
    category: '其他',
    splitType: 'equal',
    createdAt: 0,
    note: '',
    payerName: ''
  };

  build() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 6 }) {
          Text(this.bill.title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .alignSelf(ItemAlign.Start)
          Text(`${this.bill.category} · 付款人：${this.bill.payerName || '未知'}`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .layoutWeight(1)

        Text(FormatUtils.formatCurrency(this.bill.amount))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.brand_color'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Top)

      Row() {
        Text(this.bill.splitType === 'equal' ? '等额分摊' : '自定义分摊')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
        Text(FormatUtils.formatDateTime(this.bill.createdAt))
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.surface_color'))
    .borderRadius(18)
    .onClick(() => {
      if (!this.clickable) {
        return;
      }
    })
  }
}
