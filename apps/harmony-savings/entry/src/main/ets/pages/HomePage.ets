import router from '@ohos.router'
import { GoalWithStats } from '../model/Goal'
import { GoalViewModel } from '../viewmodel/GoalViewModel'
import { GoalCard } from '../components/GoalCard'

@Entry
@Component
export struct HomePage {
  @State private goals: GoalWithStats[] = []
  @State private loading: boolean = true
  private goalViewModel: GoalViewModel = new GoalViewModel()

  aboutToAppear(): void {
    this.loadGoals()
  }

  private async loadGoals(): Promise<void> {
    this.loading = true
    this.goals = await this.goalViewModel.getGoals()
    this.loading = false
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column({ space: 16 }) {
        Row() {
          Column({ space: 6 }) {
            Text('HarmonySavings')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F1F1F')
            Text('追踪每一个储蓄目标的进度')
              .fontSize(14)
              .fontColor('#666666')
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Button('设置')
            .type(ButtonType.Capsule)
            .fontSize(14)
            .onClick(() => {
              router.pushUrl({ url: 'pages/SettingsPage' })
            })
        }
        .width('100%')

        if (this.loading) {
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
          }
          .width('100%')
          .height('70%')
          .justifyContent(FlexAlign.Center)
        } else if (this.goals.length === 0) {
          Column({ space: 12 }) {
            Text('还没有储蓄目标')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F1F1F')
            Text('点击右下角按钮创建你的第一个目标')
              .fontSize(14)
              .fontColor('#888888')
          }
          .width('100%')
          .height('70%')
          .justifyContent(FlexAlign.Center)
        } else {
          Grid() {
            ForEach(this.goals, (goal: GoalWithStats) => {
              GridItem() {
                GoalCard({ goal })
              }
            }, (goal: GoalWithStats) => `${goal.id}`)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .width('100%')
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, top: 24, bottom: 24 })
      .backgroundColor('#F6F8FB')

      Button('+')
        .width(56)
        .height(56)
        .borderRadius(28)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#4F7DFF')
        .margin({ right: 20, bottom: 28 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/CreateGoalPage' })
        })
    }
  }
}
