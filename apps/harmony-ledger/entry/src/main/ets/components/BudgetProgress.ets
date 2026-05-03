import { BudgetStatus } from '../data/DataModels';
import { FormatUtils } from '../utils/FormatUtils';

@Component
export struct BudgetProgress {
  @Prop status: BudgetStatus;
  @Prop currency: string = '¥';

  build() {
    Column({ space: 12 }) {
      Row() {
        Row() {
          Text(this.status.category.icon)
            .fontSize(20)
          Text(this.status.category.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 8 })
        }
        .layoutWeight(1)
        Text(`${FormatUtils.formatAmount(this.status.spent, this.currency)} / ${FormatUtils.formatAmount(this.status.budget.amount, this.currency)}`)
          .fontSize(12)
          .fontColor('#616161')
      }

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(10)
          .backgroundColor('#EEEEEE')
          .borderRadius(999)
        Row()
          .width(`${Math.min(this.status.progress, 1) * 100}%`)
          .height(10)
          .backgroundColor(this.status.overBudget ? '#D32F2F' : this.status.category.color)
          .borderRadius(999)
      }

      Text(this.status.overBudget ? `已超支 ${FormatUtils.formatAmount(Math.abs(this.status.remaining), this.currency)}` : `剩余 ${FormatUtils.formatAmount(this.status.remaining, this.currency)}`)
        .fontSize(12)
        .fontColor(this.status.overBudget ? '#D32F2F' : '#757575')
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}
