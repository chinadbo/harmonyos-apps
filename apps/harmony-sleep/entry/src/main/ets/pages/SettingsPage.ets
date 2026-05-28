import dataPreferences from '@ohos.data.preferences';
import ReminderService from '../service/ReminderService';
import promptAction from '@ohos.promptAction';

@Component
export default struct SettingsPage {
  @State targetHours: number = 8;
  @State sleepReminderHour: number = 23;
  @State sleepReminderMin: number = 0;
  @State wakeReminderHour: number = 7;
  @State wakeReminderMin: number = 0;
  @State reminderEnabled: boolean = true;
  private prefs: dataPreferences.Preferences | null = null;
  private sleepReminderId: number = -1;
  private wakeReminderId: number = -1;

  async aboutToAppear(): Promise<void> {
    try {
      this.prefs = await dataPreferences.getPreferences(getContext(this), { name: 'sleep_settings' });
      this.targetHours = (await this.prefs.get('targetDuration', 480) as number) / 60;
      this.sleepReminderHour = await this.prefs.get('reminderSleepHour', 23) as number;
      this.sleepReminderMin = await this.prefs.get('reminderSleepMin', 0) as number;
      this.wakeReminderHour = await this.prefs.get('reminderWakeHour', 7) as number;
      this.wakeReminderMin = await this.prefs.get('reminderWakeMin', 0) as number;
      this.sleepReminderId = await this.prefs.get('sleepReminderId', -1) as number;
      this.wakeReminderId = await this.prefs.get('wakeReminderId', -1) as number;
    } catch (err) {
      console.error('[SettingsPage] aboutToAppear error:', JSON.stringify(err));
    }
  }

  async saveSettings(): Promise<void> {
    try {
      if (this.prefs) {
        await this.prefs.put('targetDuration', Math.round(this.targetHours) * 60);
        await this.prefs.put('reminderSleepHour', this.sleepReminderHour);
        await this.prefs.put('reminderSleepMin', this.sleepReminderMin);
        await this.prefs.put('reminderWakeHour', this.wakeReminderHour);
        await this.prefs.put('reminderWakeMin', this.wakeReminderMin);

        // 更新提醒
        if (this.reminderEnabled) {
          if (this.sleepReminderId > 0) {
            await ReminderService.cancelReminder(this.sleepReminderId);
          }
          if (this.wakeReminderId > 0) {
            await ReminderService.cancelReminder(this.wakeReminderId);
          }
          this.sleepReminderId = await ReminderService.setSleepReminder(
            this.sleepReminderHour, this.sleepReminderMin);
          this.wakeReminderId = await ReminderService.setWakeReminder(
            this.wakeReminderHour, this.wakeReminderMin);
          await this.prefs.put('sleepReminderId', this.sleepReminderId);
          await this.prefs.put('wakeReminderId', this.wakeReminderId);
        }
        await this.prefs.flush();
        promptAction.showToast({ message: '设置已保存', duration: 2000 });
      }
    } catch (err) {
      console.error('[SettingsPage] saveSettings error:', JSON.stringify(err));
      promptAction.showToast({ message: '保存失败', duration: 2000 });
    }
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('睡眠设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Start)
          .margin({ top: 4 })

        // 目标睡眠时长
        Column({ space: 8 }) {
          Row() {
            Text('目标睡眠时长')
              .fontSize(16)
              .fontColor('#1A1A2E')
            Blank()
            Text(`${Math.round(this.targetHours)}小时`)
              .fontSize(16)
              .fontColor('#5B8DEF')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          Slider({
            value: this.targetHours,
            min: 4,
            max: 12,
            step: 0.5,
            style: SliderStyle.OutSet
          })
            .selectedColor('#5B8DEF')
            .trackColor('#E8E8E8')
            .onChange((val) => {
              this.targetHours = val;
            })
        }
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .width('100%')

        // 提醒设置
        Column({ space: 12 }) {
          Row() {
            Text('智能提醒')
              .fontSize(16)
              .fontColor('#1A1A2E')
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.reminderEnabled })
              .selectedColor('#5B8DEF')
              .onChange((isOn) => {
                this.reminderEnabled = isOn;
              })
          }
          .width('100%')

          if (this.reminderEnabled) {
            Divider().color('#F0F0F0')

            // 睡前提醒
            Row() {
              Column({ space: 2 }) {
                Text('睡前提醒')
                  .fontSize(15)
                  .fontColor('#1A1A2E')
                Text('每天晚上提醒你准备入睡')
                  .fontSize(12)
                  .fontColor('#AAAAAA')
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Text(`${this.sleepReminderHour.toString().padStart(2,'0')}:${this.sleepReminderMin.toString().padStart(2,'0')}`)
                .fontSize(16)
                .fontColor('#5B8DEF')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')

            // 起床提醒
            Row() {
              Column({ space: 2 }) {
                Text('起床提醒')
                  .fontSize(15)
                  .fontColor('#1A1A2E')
                Text('每天早晨提醒你起床')
                  .fontSize(12)
                  .fontColor('#AAAAAA')
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Text(`${this.wakeReminderHour.toString().padStart(2,'0')}:${this.wakeReminderMin.toString().padStart(2,'0')}`)
                .fontSize(16)
                .fontColor('#5B8DEF')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
          }
        }
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .width('100%')

        // 保存按钮
        Button('保存设置')
          .width('100%')
          .height(52)
          .backgroundColor('#5B8DEF')
          .borderRadius(26)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.saveSettings();
          })

        // 关于
        Column({ space: 4 }) {
          Text('HarmonySleep v1.0.0')
            .fontSize(14)
            .fontColor('#AAAAAA')
          Text('好的睡眠，从记录开始')
            .fontSize(12)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 8 })
      }
      .padding({ horizontal: 16, bottom: 40, top: 12 })
      .width('100%')
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#F8F9FA')
    .width('100%')
    .height('100%')
  }
}
