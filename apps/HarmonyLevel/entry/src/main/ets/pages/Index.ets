import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { PrefsHelper } from '../data/PrefsHelper';
import { MeasureRecord, MODE_BUBBLE, MODE_RULER, formatAngle, formatTs, modeLabel } from '../model/Measure';

@Entry
@Component
struct Index {
  @State recentRecords: MeasureRecord[] = [];

  aboutToAppear(): void {
    this.loadRecent();
  }

  onPageShow(): void {
    this.loadRecent();
  }

  private async loadRecent(): Promise<void> {
    const list: MeasureRecord[] = await PrefsHelper.getHistory(getContext(this) as common.Context);
    this.recentRecords = list.slice(0, 3);
  }

  private recordAngleText(rec: MeasureRecord): string {
    if (rec.mode === MODE_RULER) {
      return `${formatAngle(rec.angleX)}°`;
    }
    return `X ${formatAngle(rec.angleX)}° / Y ${formatAngle(rec.angleY)}°`;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 4 }) {
          Text('水平仪')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#e8edf2')
          Text('传感器倾角测量 · 零权限 · 纯本地')
            .fontSize(12)
            .fontColor('#93a1b0')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ top: 12 })

        Row({ space: 12 }) {
          Column({ space: 8 }) {
            Circle({ width: 44, height: 44 }).fill('#35e08a').opacity(0.9)
            Text('气泡水平仪')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#e8edf2')
            Text('双轴 · 桌面台面校平')
              .fontSize(12)
              .fontColor('#93a1b0')
          }
          .layoutWeight(1)
          .padding(16)
          .borderRadius(16)
          .backgroundColor('#1a222c')
          .border({ width: 1, color: '#2c3947' })
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            router.pushUrl({ url: 'pages/BubblePage' });
          })

          Column({ space: 8 }) {
            Circle({ width: 44, height: 44 }).fill('#37c8f0').opacity(0.9)
            Text('角度尺')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#e8edf2')
            Text('单轴 · 贴墙斜面测角')
              .fontSize(12)
              .fontColor('#93a1b0')
          }
          .layoutWeight(1)
          .padding(16)
          .borderRadius(16)
          .backgroundColor('#1a222c')
          .border({ width: 1, color: '#2c3947' })
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            router.pushUrl({ url: 'pages/RulerPage' });
          })
        }
        .width('100%')

        Column({ space: 12 }) {
          Row() {
            Text('最近测量')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#e8edf2')
            Blank()
            Text('全部记录')
              .fontSize(13)
              .fontColor('#37c8f0')
              .onClick(() => {
                router.pushUrl({ url: 'pages/HistoryPage' });
              })
          }
          .width('100%')

          if (this.recentRecords.length === 0) {
            Text('暂无测量记录')
              .fontSize(13)
              .fontColor('#93a1b0')
              .padding(16)
          } else {
            ForEach(this.recentRecords, (rec: MeasureRecord) => {
              Row() {
                Text(modeLabel(rec.mode))
                  .fontSize(13)
                  .fontColor('#37c8f0')
                Blank()
                Column({ space: 2 }) {
                  Text(this.recordAngleText(rec))
                    .fontSize(14)
                    .fontColor('#e8edf2')
                  Text(formatTs(rec.ts))
                    .fontSize(11)
                    .fontColor('#93a1b0')
                }
                .alignItems(HorizontalAlign.End)
              }
              .width('100%')
              .padding({ left: 14, right: 14, top: 10, bottom: 10 })
              .borderRadius(12)
              .backgroundColor('#1a222c')
            }, (rec: MeasureRecord) => rec.id.toString())
          }
        }
        .width('100%')
        .padding(16)
        .borderRadius(16)
        .backgroundColor('#161d26')
        .border({ width: 1, color: '#2c3947' })

        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Text('校准')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#e8edf2')
            Text('三步置零')
              .fontSize(11)
              .fontColor('#93a1b0')
          }
          .layoutWeight(1)
          .padding(14)
          .borderRadius(12)
          .backgroundColor('#1a222c')
          .border({ width: 1, color: '#2c3947' })
          .onClick(() => {
            router.pushUrl({ url: 'pages/CalibratePage' });
          })

          Column({ space: 4 }) {
            Text('记录')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#e8edf2')
            Text('历史测量')
              .fontSize(11)
              .fontColor('#93a1b0')
          }
          .layoutWeight(1)
          .padding(14)
          .borderRadius(12)
          .backgroundColor('#1a222c')
          .border({ width: 1, color: '#2c3947' })
          .onClick(() => {
            router.pushUrl({ url: 'pages/HistoryPage' });
          })

          Column({ space: 4 }) {
            Text('设置')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#e8edf2')
            Text('灵敏度/声音')
              .fontSize(11)
              .fontColor('#93a1b0')
          }
          .layoutWeight(1)
          .padding(14)
          .borderRadius(12)
          .backgroundColor('#1a222c')
          .border({ width: 1, color: '#2c3947' })
          .onClick(() => {
            router.pushUrl({ url: 'pages/SettingsPage' });
          })
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0e1319')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }
}
