import router from '@ohos.router';
import { InstrumentPreset, InstrumentConfig } from '../tuner/InstrumentConfig';

@Entry
@Component
struct InstrumentSelect {
  @State instruments: InstrumentPreset[] = InstrumentConfig.ALL_INSTRUMENTS;
  @State currentInstrumentName: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params && params['currentInstrument']) {
      this.currentInstrumentName = params['currentInstrument'];
    }
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

        Text('Select Instrument')
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

      List() {
        ForEach(this.instruments, (preset: InstrumentPreset, index: number) => {
          ListItem() {
            Row() {
              Column() {
                Text(preset.name)
                  .fontSize(20)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')

                Text(preset.notes.join(' '))
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              if (this.currentInstrumentName === preset.name) {
                Text('✓')
                  .fontSize(24)
                  .fontColor('#4CAF50')
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.currentInstrumentName === preset.name ? '#F0F8F0' : '#FFFFFF')
            .borderRadius(8)
            .onClick(() => {
              router.back({
                params: { selectedInstrument: preset.name }
              });
            })
          }
        }, (preset: InstrumentPreset) => preset.name)
      }
      .padding(12)
      .divider({ strokeWidth: 1, color: '#F0F0F0' })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
