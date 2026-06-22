import router from '@ohos.router';
import { ReminderSettings } from '../model/GoalModel';
import { goalViewModel } from '../viewmodel/GoalViewModel';

@Entry
@Component
struct SettingsPage {
  @StorageProp('reminderSettings') reminderSettings: ReminderSettings = {
    enabled: false,
    hour: 21,
    minute: 0,
    reminderId: 1001
  };
  @State enabled: boolean = false;
  @State hourText: string = '21';
  @State minuteText: string = '00';

  aboutToAppear(): void {
    this.enabled = this.reminderSettings.enabled;
    this.hourText = `${this.reminderSettings.hour}`;
    this.minuteText = `${this.reminderSettings.minute}`;
  }

  private async save(): Promise<void> {
    let hour: number = Number(this.hourText);
    let minute: number = Number(this.minuteText);
    if (hour < 0) {
      hour = 0;
    }
    if (hour > 23) {
      hour = 23;
    }
    if (minute < 0) {
      minute = 0;
    }
    if (minute > 59) {
      minute = 59;
    }
    await goalViewModel.saveReminderSettings(this.enabled, hour, minute);
    router.back();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('返回')
            .height(36)
            .backgroundColor('#F3F5F8')
            .fontColor('#18202A')
            .onClick(() => router.back())
          Text('提醒设置')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 12 })
        }
        .width('100%')

        Column({ space: 14 }) {
          Row() {
            Column({ space: 4 }) {
              Text('启用每日提醒')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
              Text('在固定时间提醒你回顾当天的目标进展。')
                .fontSize(13)
                .fontColor('#5E6B7A')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.enabled })
              .selectedColor('#4C7DFF')
              .onChange((value: boolean) => this.enabled = value)
          }
          .width('100%')

          Text('提醒时间')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)

          Row({ space: 12 }) {
            TextInput({ text: this.hourText, placeholder: '21' })
              .layoutWeight(1)
              .height(44)
              .type(InputType.Number)
              .backgroundColor('#F8FAFD')
              .onChange((value: string) => this.hourText = value)
            Text(':')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
            TextInput({ text: this.minuteText, placeholder: '00' })
              .layoutWeight(1)
              .height(44)
              .type(InputType.Number)
              .backgroundColor('#F8FAFD')
              .onChange((value: string) => this.minuteText = value)
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        Button('保存设置')
          .width('100%')
          .height(46)
          .backgroundColor('#4C7DFF')
          .onClick(async () => await this.save())
      }
      .padding(16)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F8FB')
  }
}
