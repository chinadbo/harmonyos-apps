import { databaseService } from '../services/DatabaseService'
import { HeatmapChart } from '../components/HeatmapChart'
import { BarChart } from '../components/BarChart'

@Component
export struct StatisticsPage {
  @State dailyData: Record<string, number> = {}
  @State modeSummary: Record<string, number> = {
    FOCUS: 0,
    SHORT_BREAK: 0,
    LONG_BREAK: 0
  }

  async aboutToAppear(): Promise<void> {
    await this.loadData()
  }

  private async loadData(): Promise<void> {
    this.dailyData = await databaseService.getDailyFocusCounts(28)
    this.modeSummary = await databaseService.getModeSummary()
  }

  private getTotalFocusCount(): number {
    let total: number = 0
    Object.keys(this.dailyData).forEach((key: string) => {
      total += this.dailyData[key] ?? 0
    })
    return total
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row({ space: 12 }) {
          Column({ space: 8 }) {
            Text('累计专注')
              .fontSize(14)
              .fontColor('#868E96')
            Text(`${this.getTotalFocusCount()} 次`)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#212529')
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)

          Column({ space: 8 }) {
            Text('短休息')
              .fontSize(14)
              .fontColor('#868E96')
            Text(`${this.modeSummary['SHORT_BREAK'] ?? 0} 次`)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#51CF66')
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
        }

        HeatmapChart({ data: this.dailyData, days: 28 })

        BarChart({
          labels: ['专注', '短休', '长休'],
          values: [
            this.modeSummary['FOCUS'] ?? 0,
            this.modeSummary['SHORT_BREAK'] ?? 0,
            this.modeSummary['LONG_BREAK'] ?? 0
          ],
          colors: ['#FF6B6B', '#51CF66', '#74C0FC']
        })

        Button('刷新统计')
          .width('100%')
          .height(44)
          .backgroundColor('#212529')
          .onClick(() => this.loadData())
      }
      .padding(16)
      .width('100%')
    }
    .backgroundColor('#F8F9FA')
    .height('100%')
    .width('100%')
  }
}
