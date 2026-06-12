import router from '@ohos.router'
import { GoalWithStats } from '../model/Goal'

@Component
export struct GoalCard {
  @Prop goal: GoalWithStats

  private get isCompleted(): boolean {
    return this.goal.progress >= 1
  }

  private formatCurrency(amountInCent: number): string {
    return `¥${(amountInCent / 100).toFixed(2)}`
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Text(this.goal.name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F1F1F')
          .layoutWeight(1)
        Text(`${Math.round(this.goal.progress * 100)}%`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(isCompleted ? '#20A162' : this.goal.color)
      }
      .width('100%')

      Text(`已存 ${this.formatCurrency(this.goal.currentAmount)} / ${this.formatCurrency(this.goal.targetAmount)}`)
        .fontSize(14)
        .fontColor('#444444')

      Progress({ value: this.goal.currentAmount, total: this.goal.targetAmount, type: ProgressType.Linear })
        .height(8)
        .color(isCompleted ? '#20A162' : this.goal.color)
        .backgroundColor('#E8ECF4')
        .borderRadius(999)

      Row() {
        Text(`截止 ${this.goal.deadline}`)
          .fontSize(12)
          .fontColor('#666666')
        Blank()
        Text(`记录 ${this.goal.depositCount}`)
          .fontSize(12)
          .fontColor('#666666')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({ radius: 12, color: '#14000000', offsetX: 0, offsetY: 6 })
    .border({ width: 1, color: isCompleted ? '#CDEEDB' : '#EEF2F8' })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/GoalDetailPage',
        params: {
          goalId: this.goal.id
        }
      })
    })
  }
}
