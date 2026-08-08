@Component
export struct SettingsPage {
  @Prop use24Hour: boolean = true
  @Prop vibrationEnabled: boolean = true
  @Prop defaultTimerSeconds: number = 300
  onUse24HourChange: (value: boolean) => void = (_value: boolean): void => {}
  onVibrationChange: (value: boolean) => void = (_value: boolean): void => {}
  onDefaultTimerChange: (value: number) => void = (_value: number): void => {}

  build() {
    Column({ space: 12 }) {
      Text('Settings')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)

      Column({ space: 12 }) {
        Row() {
          Text('24-hour time')
            .fontSize(16)
            .layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.use24Hour })
            .onChange((value: boolean) => {
              if (this.onUse24HourChange) {
                this.onUse24HourChange(value)
              }
            })
        }
        .width('100%')

        Row() {
          Text('Vibration')
            .fontSize(16)
            .layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.vibrationEnabled })
            .onChange((value: boolean) => {
              if (this.onVibrationChange) {
                this.onVibrationChange(value)
              }
            })
        }
        .width('100%')

        Column({ space: 8 }) {
          Text('Default timer')
            .fontSize(16)
            .width('100%')
          Row({ space: 8 }) {
            Button('1 min')
              .type(ButtonType.Capsule)
              .layoutWeight(1)
              .backgroundColor(this.defaultTimerSeconds === 60 ? '#317AF7' : '#FFFFFF')
              .fontColor(this.defaultTimerSeconds === 60 ? '#FFFFFF' : '#222222')
              .onClick(() => {
                if (this.onDefaultTimerChange) {
                  this.onDefaultTimerChange(60)
                }
              })
            Button('5 min')
              .type(ButtonType.Capsule)
              .layoutWeight(1)
              .backgroundColor(this.defaultTimerSeconds === 300 ? '#317AF7' : '#FFFFFF')
              .fontColor(this.defaultTimerSeconds === 300 ? '#FFFFFF' : '#222222')
              .onClick(() => {
                if (this.onDefaultTimerChange) {
                  this.onDefaultTimerChange(300)
                }
              })
            Button('10 min')
              .type(ButtonType.Capsule)
              .layoutWeight(1)
              .backgroundColor(this.defaultTimerSeconds === 600 ? '#317AF7' : '#FFFFFF')
              .fontColor(this.defaultTimerSeconds === 600 ? '#FFFFFF' : '#222222')
              .onClick(() => {
                if (this.onDefaultTimerChange) {
                  this.onDefaultTimerChange(600)
                }
              })
          }
          .width('100%')
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
