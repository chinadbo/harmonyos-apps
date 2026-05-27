import { ProjectDurationStat, DailyDurationStat } from '../model/Stats'
import { PieChart } from '../components/PieChart'
import { BarChart } from '../components/BarChart'
import { DatabaseHelper } from '../database/DatabaseHelper'

@Component
export struct StatsPage {
  @State currentTab: number = 0
  @State pieData: ProjectDurationStat[] = []
  @State barData: DailyDurationStat[] = []
  @State projectStats: ProjectDurationStat[] = []

  aboutToAppear(): void {
    this.loadStats()
  }

  private async loadStats(): Promise<void> {
    const db = DatabaseHelper.getInstance()
    const now = Date.now()
    let startTime: number = 0

    if (this.currentTab === 0) {
      // Today
      const today = new Date()
      today.setHours(0, 0, 0, 0)
      startTime = today.getTime()
    } else if (this.currentTab === 1) {
      // This week
      const weekStart = new Date()
      weekStart.setDate(weekStart.getDate() - weekStart.getDay())
      weekStart.setHours(0, 0, 0, 0)
      startTime = weekStart.getTime()
    } else {
      // This month
      const monthStart = new Date()
      monthStart.setDate(1)
      monthStart.setHours(0, 0, 0, 0)
      startTime = monthStart.getTime()
    }

    this.projectStats = await db.getProjectDurationStats(startTime, now)
    this.pieData = this.projectStats
    this.barData = await db.getDailyDurationStats(startTime, now)
  }

  private formatDuration(seconds: number): string {
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    if (h > 0) {
      return `${h}h ${m}m`
    }
    return `${m}m`
  }

  build() {
    Column() {
      // Period tabs
      Tabs({ barPosition: BarPosition.Start }) {
        TabContent() {
          this.StatsContent()
        }
        .tabBar('今日')

        TabContent() {
          this.StatsContent()
        }
        .tabBar('本周')

        TabContent() {
          this.StatsContent()
        }
        .tabBar('本月')
      }
      .barMode(BarMode.Fixed)
      .barHeight(44)
      .onChange((index: number) => {
        this.currentTab = index
        this.loadStats()
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StatsContent() {
    Scroll() {
      Column() {
        // Pie chart
        PieChart({ chartData: this.pieData })
          .margin({ top: 16 })

        // Bar chart
        BarChart({ barData: this.barData })
          .margin({ top: 24 })

        // Project list
        Column() {
          Text('项目统计')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 12 })

          if (this.projectStats.length === 0) {
            Text('暂无统计数据')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 16 })
          } else {
            ForEach(this.projectStats, (stat: ProjectDurationStat) => {
              Row() {
                Circle()
                  .width(10)
                  .height(10)
                  .fill(stat.color)
                  .margin({ right: 10 })

                Text(stat.projectName)
                  .fontSize(15)
                  .fontColor('#333333')
                  .layoutWeight(1)

                Text(this.formatDuration(stat.duration))
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .width('100%')
              .height(44)
              .padding({ left: 16, right: 16 })
            })
          }
        }
        .width('100%')
        .margin({ top: 24 })
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
    .layoutWeight(1)
  }
}
