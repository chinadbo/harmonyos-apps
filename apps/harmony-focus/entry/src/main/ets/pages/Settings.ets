import { AppSettings } from '../model/AppSettings'
import {
  AppDefaults,
  FOCUS_DURATION_OPTIONS,
  LONG_BREAK_INTERVAL_OPTIONS,
  LONG_BREAK_OPTIONS,
  SHORT_BREAK_OPTIONS,
  WHITE_NOISE_LABELS,
  WhiteNoiseType
} from '../common/Constants'
import { databaseService } from '../services/DatabaseService'
import { timerService } from '../services/TimerService'
import { audioService } from '../services/AudioService'

@Component
export struct SettingsPage {
  @Prop onSettingsSaved: () => void = () => {}
  @State settings: AppSettings = new AppSettings()
  @State saving: boolean = false

  async aboutToAppear(): Promise<void> {
    await this.loadSettings()
  }

  private async loadSettings(): Promise<void> {
    this.settings = await databaseService.getSettings()
    AppStorage.SetOrCreate(AppDefaults.STORAGE_NOTIFICATION_ENABLED, this.settings.notificationEnabled)
  }

  private cloneSettings(): AppSettings {
    return new AppSettings(
      this.settings.id,
      this.settings.focusMinutes,
      this.settings.shortBreakMinutes,
      this.settings.longBreakMinutes,
      this.settings.longBreakInterval,
      this.settings.whiteNoiseType,
      this.settings.notificationEnabled
    )
  }

  private async saveSettings(): Promise<void> {
    this.saving = true
    await databaseService.saveSettings(this.settings)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_NOTIFICATION_ENABLED, this.settings.notificationEnabled)
    await timerService.hydrateFromSettings(this.settings)
    if (this.settings.whiteNoiseType === WhiteNoiseType.NONE) {
      await audioService.stop()
    }
    this.onSettingsSaved()
    this.saving = false
  }

  private updateFocusMinutes(value: number): void {
    const next = this.cloneSettings()
    next.focusMinutes = value
    this.settings = next
  }

  private updateShortBreakMinutes(value: number): void {
    const next = this.cloneSettings()
    next.shortBreakMinutes = value
    this.settings = next
  }

  private updateLongBreakMinutes(value: number): void {
    const next = this.cloneSettings()
    next.longBreakMinutes = value
    this.settings = next
  }

  private updateLongBreakInterval(value: number): void {
    const next = this.cloneSettings()
    next.longBreakInterval = value
    this.settings = next
  }

  private updateWhiteNoise(value: WhiteNoiseType): void {
    const next = this.cloneSettings()
    next.whiteNoiseType = value
    this.settings = next
  }

  private toggleNotification(): void {
    const next = this.cloneSettings()
    next.notificationEnabled = !next.notificationEnabled
    this.settings = next
  }

  @Builder
  private buildOptionGroup(title: string, options: number[], currentValue: number, onSelect: (value: number) => void) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)
      Flex({ wrap: FlexWrap.Wrap, direction: FlexDirection.Row }) {
        ForEach(options, (option: number) => {
          Button(`${option}`)
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(currentValue === option ? '#FF6B6B' : '#E9ECEF')
            .fontColor(currentValue === option ? '#FFFFFF' : '#212529')
            .onClick(() => onSelect(option))
        }, (option: number) => `${option}`)
      }
    }
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.buildOptionGroup('专注时长（分钟）', FOCUS_DURATION_OPTIONS, this.settings.focusMinutes, (value: number) => this.updateFocusMinutes(value))
        this.buildOptionGroup('短休息（分钟）', SHORT_BREAK_OPTIONS, this.settings.shortBreakMinutes, (value: number) => this.updateShortBreakMinutes(value))
        this.buildOptionGroup('长休息（分钟）', LONG_BREAK_OPTIONS, this.settings.longBreakMinutes, (value: number) => this.updateLongBreakMinutes(value))
        this.buildOptionGroup('每 N 个番茄后长休息', LONG_BREAK_INTERVAL_OPTIONS, this.settings.longBreakInterval, (value: number) => this.updateLongBreakInterval(value))

        Column({ space: 8 }) {
          Text('白噪音类型')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Start)
          Flex({ wrap: FlexWrap.Wrap, direction: FlexDirection.Row }) {
            ForEach(Object.keys(WHITE_NOISE_LABELS), (key: string) => {
              Button(WHITE_NOISE_LABELS[key])
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.settings.whiteNoiseType === key ? '#51CF66' : '#E9ECEF')
                .fontColor(this.settings.whiteNoiseType === key ? '#FFFFFF' : '#212529')
                .onClick(() => this.updateWhiteNoise(key as WhiteNoiseType))
            }, (key: string) => key)
          }
        }

        Row() {
          Column({ space: 6 }) {
            Text('通知提醒')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Text(this.settings.notificationEnabled ? '已开启计时结束通知' : '已关闭计时结束通知')
              .fontSize(12)
              .fontColor('#868E96')
          }
          .layoutWeight(1)
          Button(this.settings.notificationEnabled ? '关闭' : '开启')
            .backgroundColor(this.settings.notificationEnabled ? '#FFF5F5' : '#E6FCF5')
            .fontColor(this.settings.notificationEnabled ? '#E03131' : '#2B8A3E')
            .onClick(() => this.toggleNotification())
        }
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Button(this.saving ? '保存中...' : '保存设置')
          .enabled(!this.saving)
          .width('100%')
          .height(44)
          .backgroundColor('#212529')
          .onClick(() => this.saveSettings())
      }
      .padding(16)
      .width('100%')
    }
    .backgroundColor('#F8F9FA')
    .height('100%')
    .width('100%')
  }
}
