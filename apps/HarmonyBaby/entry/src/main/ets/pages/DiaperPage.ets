import { DatabaseHelper, makeDiaperRecord } from '../database/DatabaseHelper';
import {
  DiaperRecord,
  DiaperType,
  PeriodRecords,
  buildDailyRecords,
  DailyRecord,
  diaperIcon,
  diaperTitle
} from '../model/Models';
import { Theme } from '../utils/Theme';
import { TimeUtils } from '../utils/TimeUtils';
import { RecordCard } from '../components/RecordCard';

/**
 * 换尿布页：类型选择（小便/大便/混合/干爽）+ 备注 + 打卡 + 今日列表
 */
@Component
export struct DiaperPage {
  @StorageLink('dataVersion') @Watch('onReload') dataVersion: number = 0;
  @State selectedType: string = DiaperType.Wet;
  @State note: string = '';
  @State todayDiapers: DiaperRecord[] = [];
  @State dailyRecords: DailyRecord[] = [];

  aboutToAppear(): void {
    this.loadToday();
  }

  onReload(): void {
    this.loadToday();
  }

  private async loadToday(): Promise<void> {
    try {
      const start = TimeUtils.todayStart();
      const records: PeriodRecords =
        await DatabaseHelper.getInstance().queryPeriodRecords(start, start + TimeUtils.DAY);
      this.todayDiapers = records.diapers;
      this.dailyRecords = buildDailyRecords(records);
    } catch (e) {
      console.error('DiaperPage loadToday failed: ' + e);
    }
  }

  private wetCountToday(): number {
    let count = 0;
    for (let i = 0; i < this.todayDiapers.length; i++) {
      const t = this.todayDiapers[i].type;
      if (t === DiaperType.Wet || t === DiaperType.Mixed) {
        count++;
      }
    }
    return count;
  }

  private dirtyCountToday(): number {
    let count = 0;
    for (let i = 0; i < this.todayDiapers.length; i++) {
      const t = this.todayDiapers[i].type;
      if (t === DiaperType.Dirty || t === DiaperType.Mixed) {
        count++;
      }
    }
    return count;
  }

  private lastChangeHint(): string {
    if (this.todayDiapers.length === 0) {
      return '今天还没有换过尿布';
    }
    const latest = this.todayDiapers[0];
    return '上次换尿布：' + TimeUtils.agoText(latest.changeTime, Date.now());
  }

  private async save(): Promise<void> {
    const record = makeDiaperRecord(this.selectedType, this.note.trim());
    await DatabaseHelper.getInstance().insertDiaper(record);
    this.note = '';
    this.dataVersion++;
  }

  private async deleteRecord(kind: string, recordId: number): Promise<void> {
    if (kind !== 'diaper') {
      return;
    }
    await DatabaseHelper.getInstance().deleteDiaper(recordId);
    this.dataVersion++;
  }

  @Builder
  typeChip(type: string) {
    Column() {
      Text(diaperIcon(type))
        .fontSize(26)
      Text(diaperTitle(type))
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.selectedType === type ? Theme.PRIMARY : Theme.TEXT)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ top: 14, bottom: 14 })
    .backgroundColor(this.selectedType === type ? Theme.ORANGE_LIGHT : Theme.CARD)
    .borderRadius(14)
    .border({
      width: this.selectedType === type ? 2 : 1,
      color: this.selectedType === type ? Theme.PRIMARY : Theme.BORDER
    })
    .onClick(() => {
      this.selectedType = type;
    })
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Column() {
            Text(this.todayDiapers.length.toString())
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.PRIMARY)
            Text('今日更换')
              .fontSize(12)
              .fontColor(Theme.TEXT_SUB)
          }
          .layoutWeight(1)

          Column() {
            Text(this.wetCountToday().toString())
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.BLUE)
            Text('小便 💦')
              .fontSize(12)
              .fontColor(Theme.TEXT_SUB)
          }
          .layoutWeight(1)

          Column() {
            Text(this.dirtyCountToday().toString())
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.GREEN)
            Text('大便 💩')
              .fontSize(12)
              .fontColor(Theme.TEXT_SUB)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(14)
        .backgroundColor(Theme.CARD)
        .borderRadius(16)

        Row() {
          Text('选择尿布状态')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT)
          Blank()
          Text(this.lastChangeHint())
            .fontSize(12)
            .fontColor(Theme.TEXT_SUB)
        }
        .width('100%')
        .margin({ top: 20, bottom: 10 })

        Row({ space: 8 }) {
          this.typeChip(DiaperType.Wet)
          this.typeChip(DiaperType.Dirty)
          this.typeChip(DiaperType.Mixed)
          this.typeChip(DiaperType.Dry)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: 12 })

        Column() {
          TextInput({ placeholder: '备注（可选），如：红屁屁、量多' })
            .height(42)
            .fontSize(14)
            .backgroundColor(Theme.GRAY_BG)
            .onChange((value: string) => {
              this.note = value;
            })
          Button('换好了，打卡')
            .width('100%')
            .height(42)
            .fontSize(15)
            .backgroundColor(Theme.PRIMARY)
            .margin({ top: 12 })
            .onClick(() => {
              this.save();
            })
        }
        .width('100%')
        .padding(14)
        .backgroundColor(Theme.CARD)
        .borderRadius(16)

        Row() {
          Text('今日记录')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT)
          Blank()
          Text(this.todayDiapers.length + ' 条')
            .fontSize(12)
            .fontColor(Theme.TEXT_SUB)
        }
        .width('100%')
        .margin({ top: 20, bottom: 10 })

        if (this.dailyRecords.length === 0) {
          Text('还没有记录，换完尿布记得打卡哦')
            .fontSize(13)
            .fontColor(Theme.TEXT_LIGHT)
            .margin({ top: 24, bottom: 24 })
        } else {
          List() {
            ForEach(this.dailyRecords, (item: DailyRecord) => {
              ListItem() {
                RecordCard({
                  icon: item.icon,
                  title: item.title,
                  subtitle: item.subtitle,
                  timeMs: item.timeMs,
                  deletable: true,
                  kind: item.kind,
                  recordId: item.recordId,
                  onDelete: (kind: string, recordId: number) => {
                    this.deleteRecord(kind, recordId);
                  }
                })
              }
              .margin({ bottom: 8 })
            }, (item: DailyRecord) => item.kind + item.recordId.toString())
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
  }
}
