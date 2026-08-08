import { AlarmModel } from '../models/AlarmModel'
import { TimeUtils } from '../utils/TimeUtils'

@Component
export struct AlarmPage {
  @Prop alarms: Array<AlarmModel> = []
  @Prop use24Hour: boolean = true
  onAddAlarm: () => void = (): void => {}
  onToggleAlarm: (alarmId: number, enabled: boolean) => void = (_alarmId: number, _enabled: boolean): void => {}
  onDeleteAlarm: (alarmId: number) => void = (_alarmId: number): void => {}

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('Alarms')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)

        Button('Add')
          .type(ButtonType.Capsule)
          .onClick(() => {
            if (this.onAddAlarm) {
              this.onAddAlarm()
            }
          })
      }
      .width('100%')

      if (this.alarms.length === 0) {
        Text('No alarms configured')
          .fontSize(15)
          .fontColor('#666666')
          .width('100%')
      } else {
        ForEach(this.alarms, (alarm: AlarmModel) => {
          Row() {
            Column({ space: 4 }) {
              Text(TimeUtils.formatTime(alarm.hour, alarm.minute, this.use24Hour))
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
              Text(alarm.label.length > 0 ? alarm.label : 'Alarm')
                .fontSize(14)
                .fontColor('#666666')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              Toggle({ type: ToggleType.Switch, isOn: alarm.enabled })
                .onChange((isOn: boolean) => {
                  if (this.onToggleAlarm) {
                    this.onToggleAlarm(alarm.id, isOn)
                  }
                })
              Button('Delete')
                .type(ButtonType.Capsule)
                .fontSize(12)
                .onClick(() => {
                  if (this.onDeleteAlarm) {
                    this.onDeleteAlarm(alarm.id)
                  }
                })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
        }, (alarm: AlarmModel) => `${alarm.id}`)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
