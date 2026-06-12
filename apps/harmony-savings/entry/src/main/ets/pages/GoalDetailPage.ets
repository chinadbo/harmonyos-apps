import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { Goal } from '../model/Goal'
import { Deposit } from '../model/Deposit'
import { GoalViewModel } from '../viewmodel/GoalViewModel'
import { DatabaseHelper } from '../database/DatabaseHelper'
import { RingProgress } from '../components/RingProgress'
import { DepositItem } from '../components/DepositItem'
import { NotificationUtils } from '../utils/NotificationUtils'

@Entry
@Component
export struct GoalDetailPage {
  @State private goal: Goal | null = null
  @State private deposits: Deposit[] = []
  @State private isCompleted: boolean = false
  @State private completionTipShown: boolean = false
  private goalId: number = 0
  private goalViewModel: GoalViewModel = new GoalViewModel()

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    this.goalId = Number(params?.goalId)
    this.loadData()
  }

  private async loadData(): Promise<void> {
    if (!this.goalId) {
      return
    }
    const data = await DatabaseHelper.getInstance().getGoalWithDeposits(this.goalId)
    this.goal = data.goal
    this.deposits = data.deposits
    if (this.goal !== null) {
      this.isCompleted = this.goal.currentAmount >= this.goal.targetAmount
      if (this.isCompleted && !this.completionTipShown) {
        this.completionTipShown = true
        promptAction.showToast({ message: `恭喜完成目标：${this.goal.name}` })
        NotificationUtils.publishGoalCompleted(this.goal.name)
      }
    }
  }

  private progress(): number {
    if (this.goal === null || this.goal.targetAmount <= 0) {
      return 0
    }
    return Math.min(this.goal.currentAmount / this.goal.targetAmount, 1)
  }

  private formatCurrency(amountInCent: number): string {
    return this.goalViewModel.formatCurrency(amountInCent)
  }

  build() {
    if (this.goal === null) {
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F6F8FB')
    } else {
      Scroll() {
        Column({ space: 18 }) {
          Row() {
            Column({ space: 4 }) {
              Text(this.goal!.name)
                .fontSize(26)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1F1F1F')
              Text(this.isCompleted ? '目标已完成' : '持续积累，稳步达成')
                .fontSize(14)
                .fontColor(this.isCompleted ? '#20A162' : '#666666')
            }
            .alignItems(HorizontalAlign.Start)
            Blank()
            Button('编辑')
              .type(ButtonType.Capsule)
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/CreateGoalPage',
                  params: { goalId: this.goal!.id }
                })
              })
          }
          .width('100%')

          Column({ space: 20 }) {
            RingProgress({
              progress: this.progress(),
              size: 220,
              strokeWidth: 18,
              color: this.isCompleted ? '#20A162' : this.goal!.color,
              trackColor: '#E7ECF5',
              label: '储蓄进度'
            })

            Row() {
              Column({ space: 4 }) {
                Text('已存金额')
                  .fontSize(12)
                  .fontColor('#666666')
                Text(this.formatCurrency(this.goal!.currentAmount))
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Column({ space: 4 }) {
                Text('目标金额')
                  .fontSize(12)
                  .fontColor('#666666')
                Text(this.formatCurrency(this.goal!.targetAmount))
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
              }
              .alignItems(HorizontalAlign.End)
            }
            .width('100%')

            Text(`截止日期：${this.goal!.deadline}`)
              .fontSize(14)
              .fontColor('#666666')

            if (this.goal!.note) {
              Text(this.goal!.note)
                .fontSize(14)
                .fontColor('#444444')
                .width('100%')
            }

            if (this.isCompleted) {
              Text('恭喜你已经完成这个储蓄目标！')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#20A162')
                .width('100%')
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(24)

          Column({ space: 12 }) {
            Row() {
              Text('存款历史')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
              Blank()
              Button('存入')
                .type(ButtonType.Capsule)
                .backgroundColor('#4F7DFF')
                .fontColor('#FFFFFF')
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/AddDepositPage',
                    params: { goalId: this.goal!.id }
                  })
                })
            }
            .width('100%')

            if (this.deposits.length === 0) {
              Text('还没有存款记录')
                .fontSize(14)
                .fontColor('#888888')
                .width('100%')
            } else {
              Column({ space: 10 }) {
                ForEach(this.deposits, (deposit: Deposit) => {
                  Row({ space: 10 }) {
                    Column() {
                      Circle()
                        .width(10)
                        .height(10)
                        .fill('#4F7DFF')
                      Column()
                        .width(2)
                        .height(56)
                        .backgroundColor('#D8E2F1')
                    }
                    .justifyContent(FlexAlign.Start)
                    DepositItem({ deposit })
                      .layoutWeight(1)
                  }
                  .alignItems(VerticalAlign.Top)
                  .width('100%')
                }, (deposit: Deposit) => `${deposit.id}`)
              }
            }
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F6F8FB')
    }
  }
}
