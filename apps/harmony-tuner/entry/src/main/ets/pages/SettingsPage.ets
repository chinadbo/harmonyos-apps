import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { FrequencyUtils } from '../signal/FrequencyUtils';

@Entry
@Component
struct SettingsPage {
  @State referenceFreq: number = 440;
  @State sensitivity: number = 5.0;

  aboutToAppear() {
    this.referenceFreq = AppStorage.get('referenceFreq') || 440;
    this.sensitivity = AppStorage.get('sensitivity') || 5.0;
  }

  build() {
    Column() {
      Row() {
        Button() {
          Text('←')
            .fontSize(24)
            .fontColor('#333333')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        Text('Settings')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .alignItems(VerticalAlign.Center)

      Column() {
        Text('Reference Frequency')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .width('100%')
          .margin({ bottom: 8 })

        Row() {
          Slider({
            value: this.referenceFreq,
            min: 432,
            max: 444,
            step: 1
          })
            .width('70%')
            .onChange((value: number) => {
              this.referenceFreq = value;
              FrequencyUtils.setReferenceFrequency(value);
              AppStorage.set('referenceFreq', value);
            })

          Text(`${this.referenceFreq} Hz`)
            .fontSize(16)
            .fontColor('#2196F3')
            .width('30%')
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .margin({ top: 12 })
      .borderRadius(8)

      Column() {
        Text('Tuning Sensitivity')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .width('100%')
          .margin({ bottom: 8 })

        Row() {
          Slider({
            value: this.sensitivity,
            min: 1,
            max: 20,
            step: 0.5
          })
            .width('70%')
            .onChange((value: number) => {
              this.sensitivity = value;
              AppStorage.set('sensitivity', value);
            })

          Text(`${this.sensitivity.toFixed(1)} cents`)
            .fontSize(16)
            .fontColor('#2196F3')
            .width('30%')
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .margin({ top: 12 })
      .borderRadius(8)

      Button('Play Reference A4')
        .width('90%')
        .height(48)
        .backgroundColor('#2196F3')
        .fontColor('#FFFFFF')
        .margin({ top: 20 })
        .onClick(() => {
          promptAction.showToast({ message: 'Reference tone: ' + this.referenceFreq + 'Hz' });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .padding(12)
  }
}
