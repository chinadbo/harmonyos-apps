import { WorkoutRecord } from '../model/WorkoutRecord'
import { WORKOUT_TYPE_MAP, WorkoutType } from '../model/WorkoutType'

@Component
@Reusable
export struct WorkoutCard {
  @Prop record: WorkoutRecord

  private getTypeInfo() {
    return WORKOUT_TYPE_MAP.get(this.record.type as WorkoutType) ?? WORKOUT_TYPE_MAP.get(WorkoutType.OTHER)
  }

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp)
    const hour = `${date.getHours()}`.padStart(2, '0')
    const minute = `${date.getMinutes()}`.padStart(2, '0')
    return `${hour}:${minute}`
  }

  build() {
    const info = this.getTypeInfo()
    Column({ space: 12 }) {
      Row() {
        Row({ space: 10 }) {
          Text(info?.icon ?? '🏅')
            .fontSize(24)
          Column({ space: 4 }) {
            Text(info?.name ?? '其他')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1D1D1F')
            Text(this.record.note.length > 0 ? this.record.note : '保持运动，积累健康')
              .fontSize(12)
              .fontColor('#7A7F8A')
          }
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)

        Text(this.formatTime(this.record.startTime))
          .fontSize(13)
          .fontColor('#7A7F8A')
      }
      .width('100%')

      Row() {
        this.buildMetric('时长', `${this.record.duration} 分钟`)
        this.buildMetric('热量', `${this.record.calories} 千卡`)
        this.buildMetric('步数', `${this.record.steps} 步`)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding(16)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({ radius: 12, color: '#14000000', offsetX: 0, offsetY: 4 })
  }

  @Builder
  private buildMetric(label: string, value: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#8F95A3')
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1D1D1F')
    }
    .alignItems(HorizontalAlign.Start)
    .width('30%')
  }
}
