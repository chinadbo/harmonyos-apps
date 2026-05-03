import { Category, Transaction } from '../data/DataModels';
import { FormatUtils } from '../utils/FormatUtils';
import { DateUtils } from '../utils/DateUtils';

@Reusable
@Component
export struct TransactionItem {
  @Prop transaction: Transaction;
  @Prop category?: Category;
  @Prop currency: string = '¥';

  build() {
    Row() {
      Row() {
        Text(this.category?.icon ?? '🧾')
          .fontSize(24)
        Column({ space: 4 }) {
          Text(this.category?.name ?? '未分类')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          Text(this.transaction.note.length > 0 ? this.transaction.note : DateUtils.displayDate(this.transaction.date))
            .fontSize(12)
            .fontColor('#757575')
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
      }
      .layoutWeight(1)

      Column({ space: 4 }) {
        Text(FormatUtils.formatSignedAmount(this.transaction.amount, this.transaction.type, this.currency))
          .fontSize(16)
          .fontColor(this.transaction.type === 'income' ? '#2E7D32' : '#D32F2F')
          .fontWeight(FontWeight.Bold)
        Text(DateUtils.displayDate(this.transaction.date))
          .fontSize(12)
          .fontColor('#9E9E9E')
      }
      .alignItems(HorizontalAlign.End)
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}
