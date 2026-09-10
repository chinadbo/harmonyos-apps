import router from '@ohos.router'
import { AppConstants, PrecisionMode, ThemeMode } from '../common/constants'
import { AppStyles } from '../common/styles'
import { timerService } from '../services/TimerService'

@Component
export struct SettingsPage {
  @StorageLink(AppConstants.STORAGE_SOUND_ENABLED) soundEnabled: boolean = true
  @StorageLink(AppConstants.STORAGE_VIBRATION_ENABLED) vibrationEnabled: boolean = true
  @StorageLink(AppConstants.STORAGE_THEME) themeMode: ThemeMode = ThemeMode.LIGHT
  @StorageLink(AppConstants.STORAGE_PRECISION) precisionMode: PrecisionMode = PrecisionMode.HIGH

  private async updateSound(value: boolean): Promise<void> {
    this.soundEnabled = value
    await timerService.updateSetting(AppConstants.SETTING_SOUND_ENABLED, String(value))
  }

  private async updateVibration(value: boolean): Promise<void> {
    this.vibrationEnabled = value
    await timerService.updateSetting(AppConstants.SETTING_VIBRATION_ENABLED, String(value))
  }

  private async updateTheme(value: ThemeMode): Promise<void> {
    this.themeMode = value
    await timerService.updateSetting(AppConstants.SETTING_THEME, value)
  }

  private async updatePrecision(value: PrecisionMode): Promise<void> {
    this.precisionMode = value
    await timerService.updateSetting(AppConstants.SETTING_PRECISION, value)
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('Back')
            .backgroundColor('#FFFFFF')
            .fontColor('#1F2937')
            .onClick(() => router.back())
          Blank()
          Text('Settings')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
        }
        .width('100%')

        Column({ space: 14 }) {
          Row({ space: 12 }) {
            Toggle({ type: ToggleType.Switch, isOn: this.soundEnabled })
              .onChange((value: boolean) => this.updateSound(value))
            Text('Sound enabled')
              .fontSize(16)
              .fontColor('#1F2937')
          }
          Row({ space: 12 }) {
            Toggle({ type: ToggleType.Switch, isOn: this.vibrationEnabled })
              .onChange((value: boolean) => this.updateVibration(value))
            Text('Vibration enabled')
              .fontSize(16)
              .fontColor('#1F2937')
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 12 }) {
          Text('Theme')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2937')
            .width('100%')
          Row({ space: 12 }) {
            Button('Light')
              .layoutWeight(1)
              .backgroundColor(this.themeMode === ThemeMode.LIGHT ? '#4F7AF7' : '#FFFFFF')
              .fontColor(this.themeMode === ThemeMode.LIGHT ? '#FFFFFF' : '#1F2937')
              .onClick(() => this.updateTheme(ThemeMode.LIGHT))
            Button('Dark')
              .layoutWeight(1)
              .backgroundColor(this.themeMode === ThemeMode.DARK ? '#4F7AF7' : '#FFFFFF')
              .fontColor(this.themeMode === ThemeMode.DARK ? '#FFFFFF' : '#1F2937')
              .onClick(() => this.updateTheme(ThemeMode.DARK))
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 12 }) {
          Text('Precision')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2937')
            .width('100%')
          Row({ space: 12 }) {
            Button('10 ms')
              .layoutWeight(1)
              .backgroundColor(this.precisionMode === PrecisionMode.HIGH ? '#4F7AF7' : '#FFFFFF')
              .fontColor(this.precisionMode === PrecisionMode.HIGH ? '#FFFFFF' : '#1F2937')
              .onClick(() => this.updatePrecision(PrecisionMode.HIGH))
            Button('100 ms')
              .layoutWeight(1)
              .backgroundColor(this.precisionMode === PrecisionMode.NORMAL ? '#4F7AF7' : '#FFFFFF')
              .fontColor(this.precisionMode === PrecisionMode.NORMAL ? '#FFFFFF' : '#1F2937')
              .onClick(() => this.updatePrecision(PrecisionMode.NORMAL))
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(AppStyles.PAGE_HORIZONTAL_PADDING)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppStyles.BACKGROUND_COLOR)
  }
}
