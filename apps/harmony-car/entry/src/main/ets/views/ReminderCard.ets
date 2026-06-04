import { ReminderItem } from '../models/Reminder';
import { formatDate, formatMileage } from '../utils/Formatters';

@Component
export struct ReminderCard {
  @Prop reminder: ReminderItem = {
    id: 0,
    vehicleId: 0,
    reminderId: 0,
    type: '',
    title: '',
    content: '',
    triggerDate: '',
    targetMileage: 0,
    isActive: false,
    createdAt: ''
  };
  onToggle?: (reminderId: number, isActive: boolean) => void;

  build() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 6 }) {
          Text(this.reminder.title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2D3D')
            .width('100%')
            .textAlign(TextAlign.Start)
          Text(`${this.reminder.type} · ${formatDate(this.reminder.triggerDate)}`)
            .fontSize(13)
            .fontColor('#5B6B7C')
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.reminder.isActive })
          .onChange((value: boolean) => {
            if (this.onToggle) {
              this.onToggle(this.reminder.id, value);
            }
          })
      }
      .width('100%')

      Text(this.reminder.content)
        .fontSize(14)
        .fontColor('#5B6B7C')
        .width('100%')
        .textAlign(TextAlign.Start)

      if (this.reminder.targetMileage > 0) {
        Text(`目标里程 ${formatMileage(this.reminder.targetMileage)}`)
          .fontSize(13)
          .fontColor('#4E7BF2')
          .width('100%')
          .textAlign(TextAlign.Start)
      }
    }
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .width('100%')
  }
}
