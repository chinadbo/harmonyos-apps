import router from '@ohos.router'
import { ReminderService } from '../service/ReminderService'
import { AppStorageKeys, type ActiveReminder } from '../common/AppStorageKeys'
import { DateUtils } from '../common/DateUtils'

@Entry
@Component
export struct ReminderSettings {
  @StorageLink('activeReminders') activeReminders: ActiveReminder[] = []
  @StorageLink('nextFeedTime') nextFeedTime: string = '--:--'
  @State feedReminderEnabled: boolean = false
  @State selectedHour: number = 8
  @State selectedMinute: number = 0

  aboutToAppear(): void {
    this.feedReminderEnabled = this.activeReminders.some((item: ActiveReminder) => item.reminderType === 'ALARM')
    const feedTime: string = this.nextFeedTime
    if (feedTime.includes(':')) {
      const parts: string[] = feedTime.split(':')
      this.selectedHour = Number(parts[0])
      this.selectedMinute = Number(parts[1])
    }
  }

  private goBack(): void {
    const stack = AppStorage.get<NavPathStack>('navPathStack') as unknown as Record<string, Function>
    if (stack && typeof stack.pop === 'function') {
      stack.pop()
    }
    router.back()
  }

  private async updateFeedReminder(enabled: boolean): Promise<void> {
    this.feedReminderEnabled = enabled
    const service: ReminderService = new ReminderService()
    const alarmList: ActiveReminder[] = this.activeReminders.filter((item: ActiveReminder) => item.reminderType === 'ALARM')
    if (!enabled) {
      for (const item of alarmList) {
        await service.cancelReminder(item.reminderId)
      }
      AppStorage.setOrCreate(AppStorageKeys.NEXT_FEED_TIME, '--:--')
      return
    }
    for (const item of alarmList) {
      await service.cancelReminder(item.reminderId)
    }
    await service.publishFeedReminder(this.selectedHour, this.selectedMinute)
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Button('返回')
          .type(ButtonType.Capsule)
          .backgroundColor('#FFFFFF')
          .fontColor('#666666')
          .onClick(() => this.goBack())
        Blank()
        Text('提醒设置')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        Blank()
      }

      Column({ space: 16 }) {
        Row() {
          Column({ space: 4 }) {
            Text('喂食提醒')
              .fontSize(17)
              .fontWeight(FontWeight.Medium)
            Text(this.feedReminderEnabled ? `当前时间 ${DateUtils.timeLabel(this.selectedHour, this.selectedMinute)}` : '未开启')
              .fontSize(12)
              .fontColor('#888888')
          }
          .layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.feedReminderEnabled })
            .onChange((value: boolean) => {
              this.updateFeedReminder(value)
            })
        }

        TimePicker({ selected: new Date(DateUtils.toDateTimeText(new Date(), this.selectedHour, this.selectedMinute)) })
          .useMilitaryTime(true)
          .onChange((value: Object) => {
            const result = value as Record<string, string | number>
            this.selectedHour = Number(result.hour)
            this.selectedMinute = Number(result.minute)
          })

        Button('保存提醒时间')
          .width('100%')
          .onClick(() => this.updateFeedReminder(true))
      }
      .padding(16)
      .borderRadius(20)
      .backgroundColor('#FFFFFF')

      Column({ space: 10 }) {
        Text('当前活跃提醒')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .width('100%')
        ForEach(this.activeReminders, (item: ActiveReminder) => {
          Row() {
            Column({ space: 4 }) {
              Text(item.title)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
              Text(`${item.reminderType} · ${item.timeText}`)
                .fontSize(12)
                .fontColor('#888888')
            }
            .layoutWeight(1)
            Button('取消提醒')
              .type(ButtonType.Capsule)
              .backgroundColor('#FFF0F0')
              .fontColor('#D9363E')
              .onClick(() => {
                new ReminderService().cancelReminder(item.reminderId)
              })
          }
          .padding(14)
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
        }, (item: ActiveReminder) => `${item.reminderId}`)
      }
      .width('100%')
    }
    .padding(16)
    .backgroundColor('#F6F7FB')
    .height('100%')
  }
}
