import { statsService, WeeklyStatsResult } from '../services/StatsService'
import { ProgressRing } from '../components/ProgressRing'
import { StatsChart } from '../components/StatsChart'

@Entry
@Component
struct StatsPage {
  @State stats: WeeklyStatsResult = {
    daily: [],
    complianceRate: 0,
    totalMedicines: 0,
    totalSchedules: 0,
    streakDays: 0
  }

  async aboutToAppear() {
    this.stats = await statsService.getWeeklyStats()
  }

  build() {
    NavDestination() {
      Column() {
        // Header
        Row() {
          Text('服药统计')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1)
        }
        .width('100%')
        .padding(16)

        Scroll() {
          Column() {
            // Compliance rate card
            Column() {
              Row() {
                Column() {
                  Text('本周依从率')
                    .fontSize(14)
                    .fontColor('#666666')

                  Text(`${this.stats.complianceRate}%`)
                    .fontSize(36)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#2196F3')
                    .margin({ top: 8 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                ProgressRing({
                  progress: this.stats.complianceRate,
                  size: 80,
                  strokeWidth: 8,
                  progressColor: this.stats.complianceRate >= 80 ? '#4CAF50' : this.stats.complianceRate >= 50 ? '#FF9800' : '#FF5722'
                })
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ left: 16, right: 16, bottom: 8 })

            // Stats summary
            Row() {
              this.StatCard('药品数', `${this.stats.totalMedicines}`)
              this.StatCard('计划数', `${this.stats.totalSchedules}`)
              this.StatCard('连续天数', `${this.stats.streakDays}天`)
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 8 })

            // Weekly chart
            StatsChart({ data: this.stats.daily })
              .margin({ left: 16, right: 16, bottom: 8 })

            // Back button
            Row() {
              Button('返回首页', { type: ButtonType.Capsule })
                .fontSize(14)
                .fontColor('#2196F3')
                .backgroundColor('#E3F2FD')
                .onClick(() => {
                  this.getUIContext().getRouter().back()
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding(16)
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F4F7FB')
    }
    .hideTitleBar(true)
  }

  @Builder
  StatCard(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2196F3')

      Text(label)
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ right: 8 })
  }
}
