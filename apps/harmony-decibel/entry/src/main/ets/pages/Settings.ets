import settingsRepository, { AppSettings } from '../data/SettingsRepository'
import { UIContext } from '@ohos.arkui'

@Entry
@Component
struct Settings {
  @State thresholdDb: number = 85
  @State calibrationOffset: number = 0
  @State theme: string = 'light'
  @State alertEnabled: boolean = true
  @State vibrationEnabled: boolean = true
  @State isSaved: boolean = false

  aboutToAppear() {
    this.loadSettings()
  }

  async loadSettings(): Promise<void> {
    await settingsRepository.init()
    const settings = await settingsRepository.getSettings()
    this.thresholdDb = settings.thresholdDb
    this.calibrationOffset = settings.calibrationOffset
    this.theme = settings.theme
    this.alertEnabled = settings.alertEnabled
    this.vibrationEnabled = settings.vibrationEnabled
  }

  async saveSettings(): Promise<void> {
    const settings: AppSettings = {
      thresholdDb: this.thresholdDb,
      calibrationOffset: this.calibrationOffset,
      theme: this.theme,
      alertEnabled: this.alertEnabled,
      vibrationEnabled: this.vibrationEnabled
    }
    await settingsRepository.saveSettings(settings)
    this.isSaved = true
    setTimeout(() => {
      this.isSaved = false
    }, 2000)
  }

  build() {
    Column() {
      Row() {
        Button() {
          Text('← Back')
            .fontSize(16)
            .fontColor($r('app.color.primary'))
        }
        .backgroundColor('transparent')
        .onClick(() => {
          const ctx = this.getUIContext() as UIContext
          ctx.getRouter().back()
        })

        Text('Settings')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Start)

      Scroll() {
        Column() {
          // Threshold
          Column() {
            Row() {
              Text($r('app.string.threshold_label'))
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
              Text(`${this.thresholdDb.toFixed(0)} dB`)
                .fontSize(16)
                .fontColor($r('app.color.primary'))
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            Slider({
              value: this.thresholdDb,
              min: 60,
              max: 110,
              step: 1
            })
            .width('100%')
            .margin({ top: 8 })
            .onChange((value: number) => {
              this.thresholdDb = value
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .margin({ bottom: 12 })

          // Calibration
          Column() {
            Row() {
              Text($r('app.string.calibration_label'))
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
              Text(`${this.calibrationOffset >= 0 ? '+' : ''}${this.calibrationOffset.toFixed(1)} dB`)
                .fontSize(16)
                .fontColor($r('app.color.primary'))
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            Slider({
              value: this.calibrationOffset,
              min: -20,
              max: 20,
              step: 0.5
            })
            .width('100%')
            .margin({ top: 8 })
            .onChange((value: number) => {
              this.calibrationOffset = value
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .margin({ bottom: 12 })

          // Theme
          Column() {
            Text($r('app.string.theme_label'))
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 8 })

            Row() {
              Button('Light')
                .width(100)
                .backgroundColor(this.theme === 'light' ? $r('app.color.primary') : '#E0E0E0')
                .fontColor(this.theme === 'light' ? '#FFFFFF' : $r('app.color.text_primary'))
                .onClick(() => { this.theme = 'light' })

              Button('Dark')
                .width(100)
                .backgroundColor(this.theme === 'dark' ? $r('app.color.primary') : '#E0E0E0')
                .fontColor(this.theme === 'dark' ? '#FFFFFF' : $r('app.color.text_primary'))
                .onClick(() => { this.theme = 'dark' })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .margin({ bottom: 12 })

          // Toggles
          Column() {
            Row() {
              Text($r('app.string.alert_enabled'))
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
              Toggle({ type: ToggleType.Switch, isOn: this.alertEnabled })
                .onChange((isOn: boolean) => {
                  this.alertEnabled = isOn
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 12 })

            Row() {
              Text($r('app.string.vibration_enabled'))
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
              Toggle({ type: ToggleType.Switch, isOn: this.vibrationEnabled })
                .onChange((isOn: boolean) => {
                  this.vibrationEnabled = isOn
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .margin({ bottom: 12 })

          // Save button
          Button() {
            Text(this.isSaved ? 'Saved!' : 'Save Settings')
              .fontSize(18)
              .fontColor('#FFFFFF')
          }
          .width('100%')
          .height(48)
          .backgroundColor(this.isSaved ? $r('app.color.safe') : $r('app.color.primary'))
          .margin({ bottom: 12 })
          .onClick(() => {
            this.saveSettings()
          })

          // About
          Column() {
            Text($r('app.string.about'))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 8 })

            Text($r('app.string.version'))
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))

            Text('Professional noise level meter for HarmonyOS')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}

export default Settings
