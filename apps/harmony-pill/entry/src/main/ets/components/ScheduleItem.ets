import { Medicine } from '../models/MedicineModel'
import { Schedule } from '../models/ScheduleModel'
import { RecordItem } from '../models/RecordModel'

@Component
export struct ScheduleItem {
  @Prop medicine: Medicine
  @Prop schedule: Schedule
  @Prop record?: RecordItem
  onCheckIn?: () => void
  onSkip?: () => void

  private getStatusColor(): ResourceColor {
    if (this.record) {
      if (this.record.status === 1) {
        return '#4CAF50'
      } else if (this.record.status === 2) {
        return '#FF5722'
      }
    }
    return '#2196F3'
  }

  private getStatusText(): string {
    if (this.record) {
      if (this.record.status === 1) {
        return '已服用'
      } else if (this.record.status === 2) {
        return '已跳过'
      }
    }
    return '待服用'
  }

  private formatTime(): string {
    const h = String(this.schedule.hour).padStart(2, '0')
    const m = String(this.schedule.minute).padStart(2, '0')
    return `${h}:${m}`
  }

  build() {
    Row() {
      Column() {
        Text(this.formatTime())
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Text(this.medicine.name)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text(`${this.schedule.dose}${this.medicine.unit || '片'}`)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ bottom: 4 })

        Text(this.getStatusText())
          .fontSize(12)
          .fontColor(this.getStatusColor())
          .backgroundColor(this.getStatusColor() + '1A')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(4)
      }
      .alignItems(HorizontalAlign.End)

      if (!this.record || this.record.status === 0) {
        Button('打卡', { type: ButtonType.Capsule, buttonStyle: ButtonStyleMode.TEXTUAL })
          .fontSize(14)
          .fontColor('#2196F3')
          .backgroundColor('#E3F2FD')
          .padding({ left: 12, right: 12 })
          .margin({ left: 8 })
          .onClick(() => {
            if (this.onCheckIn) {
              this.onCheckIn()
            }
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: '#0D000000', offsetX: 0, offsetY: 2 })
  }
}
