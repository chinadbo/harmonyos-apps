import router from '@ohos.router';
import { TuningHistory } from '../data/TuningHistory';
import { TuningRecord } from '../data/TuningRecord';

@Entry
@Component
struct HistoryPage {
  @State history: TuningHistory = new TuningHistory();

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

        Text('Tuning History')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)

        Button('Clear')
          .fontSize(14)
          .backgroundColor('#F44336')
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.history.clear();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .alignItems(VerticalAlign.Center)

      List() {
        ForEach(this.history.getRecords(), (record: TuningRecord, index: number) => {
          ListItem() {
            Row() {
              Column() {
                Text(record.instrument)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')

                Text(`${record.targetNote} → ${record.detectedFreq.toFixed(1)} Hz`)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text(record.isInTune ? '✓ In Tune' : `${record.deviationCents > 0 ? '+' : ''}${record.deviationCents.toFixed(1)} cents`)
                .fontSize(14)
                .fontColor(record.isInTune ? '#4CAF50' : '#F44336')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .margin({ bottom: 8 })
          }
        }, (record: TuningRecord) => record.id.toString())
      }
      .padding(12)
      .layoutWeight(1)

      if (this.history.getRecords().length === 0) {
        Text('No tuning records yet')
          .fontSize(18)
          .fontColor('#999999')
          .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
