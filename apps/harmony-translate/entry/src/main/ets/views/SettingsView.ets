import { promptAction } from '@ohos.promptAction';

@Component
export struct SettingsView {
  @StorageProp('currentColorMode') currentColorMode: string = 'light';
  @State clipboardEnabled: boolean = true;
  @State version: string = '1.0.0';

  build() {
    Scroll() {
      Column() {
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ bottom: 16 })

        // Dark mode toggle
        Row() {
          Column() {
            Text('深色模式')
              .fontSize(16)
              .fontColor('#333333')
            Text('切换应用深色主题')
              .fontSize(13)
              .fontColor('#999999')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.currentColorMode === 'dark' })
            .onChange((isOn: boolean) => {
              this.currentColorMode = isOn ? 'dark' : 'light';
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .margin({ bottom: 12 })

        // Clipboard toggle
        Row() {
          Column() {
            Text('剪贴板翻译')
              .fontSize(16)
              .fontColor('#333333')
            Text('监听剪贴板变化并提示翻译')
              .fontSize(13)
              .fontColor('#999999')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.clipboardEnabled })
            .onChange((isOn: boolean) => {
              this.clipboardEnabled = isOn;
              promptAction.showToast({ message: isOn ? '已启用剪贴板监听' : '已关闭剪贴板监听' });
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .margin({ bottom: 12 })

        // About section
        Column() {
          Text('关于')
            .fontSize(16)
            .fontColor('#333333')
            .width('100%')
            .margin({ bottom: 8 })

          Row() {
            Text('鸿蒙翻译')
              .fontSize(15)
              .fontColor('#666666')
              .layoutWeight(1)

            Text(`v${this.version}`)
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .margin({ bottom: 8 })

          Text('一款轻量级多语言翻译工具，支持在线翻译与离线词典。')
            .fontSize(13)
            .fontColor('#999999')
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .margin({ bottom: 12 })

        // Privacy
        Text('隐私声明：本应用仅收集必要的翻译数据，所有数据存储在本地设备。')
          .fontSize(12)
          .fontColor('#999999')
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: 16 })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
