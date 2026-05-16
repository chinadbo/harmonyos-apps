import promptAction from '@ohos.promptAction'
import { DatabaseService } from '../service/DatabaseService'
import { PreferencesService } from '../service/PreferencesService'
import { DailyStats } from '../model/WorkoutRecord'
import { BarChart } from '../components/BarChart'

@Component
export struct StatsPage {
  @State private selectedTab: number = 0
  @State private weeklyStats: DailyStats[] = []
  @State private totalSteps: number = 0
  @State private averageSteps: number = 0
  @State private goalDays: number = 0
  @State private bestDay: DailyStats = {
    date: '',
    totalSteps: 0,
    totalCalories: 0,
    totalDuration: 0,
    recordCount: 0
  }
  @State private stepGoal: number = 8000

  async aboutToAppear(): Promise<void> {
    await this.loadStats()
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Text('统计分析')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
          .width('100%')

        Tabs({ barPosition: BarPosition.Start, index: this.selectedTab }) {
          TabContent() {
            Text('')
          }.tabBar('本周')
          TabContent() {
            Text('')
          }.tabBar('本月')
        }
        .vertical(false)
        .barHeight(40)
        .onChange((index: number) => {
          this.selectedTab = index
        })
        .width('100%')
        .height(56)

        Column({ space: 12 }) {
          Text(this.selectedTab === 0 ? '最近 7 天步数趋势' : '本月概览')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#111827')
            .width('100%')
          BarChart({ data: this.weeklyStats, maxValue: this.resolveMaxValue() })
        }
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(24)

        Row({ space: 12 }) {
          this.buildSummaryCard('本周总步数', `${this.totalSteps}`)
          this.buildSummaryCard('日均步数', `${this.averageSteps}`)
        }
        .width('100%')

        Row({ space: 12 }) {
          this.buildSummaryCard('达标天数', `${this.goalDays}`)
          this.buildSummaryCard('最佳单日', `${this.bestDay.totalSteps}`)
        }
        .width('100%')

        Column({ space: 6 }) {
          Text('最佳单日记录')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#111827')
            .width('100%')
          Text(`${this.bestDay.date} · ${this.bestDay.totalSteps} 步`)
            .fontSize(15)
            .fontColor('#4B5563')
            .width('100%')
        }
        .padding(16)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(24)
      }
      .padding(16)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F3F6FA')
  }

  @Builder
  private buildSummaryCard(title: string, value: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(13)
        .fontColor('#6B7280')
      Text(value)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }

  private async loadStats(): Promise<void> {
    try {
      this.stepGoal = await PreferencesService.getInstance().getStepGoal()
      this.weeklyStats = await DatabaseService.getInstance().getWeeklyStats()
      this.totalSteps = 0
      this.goalDays = 0
      this.bestDay = this.weeklyStats[0]
      for (let i = 0; i < this.weeklyStats.length; i++) {
        const item = this.weeklyStats[i]
        this.totalSteps += item.totalSteps
        if (item.totalSteps >= this.stepGoal) {
          this.goalDays += 1
        }
        if (item.totalSteps > this.bestDay.totalSteps) {
          this.bestDay = item
        }
      }
      this.averageSteps = this.weeklyStats.length > 0 ? Math.floor(this.totalSteps / this.weeklyStats.length) : 0
    } catch (error) {
      promptAction.showToast({ message: '加载失败' })
      console.error(`loadStats failed: ${JSON.stringify(error)}`)
    }
  }

  private resolveMaxValue(): number {
    let max = this.stepGoal
    for (let i = 0; i < this.weeklyStats.length; i++) {
      if (this.weeklyStats[i].totalSteps > max) {
        max = this.weeklyStats[i].totalSteps
      }
    }
    return max > 0 ? max : 1
  }
}
