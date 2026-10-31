import { DatabaseHelper } from '../database/DatabaseHelper';
import { PeriodRecords, DailyRecord, buildDailyRecords } from '../model/Models';
import { Theme } from '../utils/Theme';
import { TimeUtils } from '../utils/TimeUtils';
import { CalendarHeat } from '../components/CalendarHeat';
import { RecordCard } from '../components/RecordCard';

/**
 * 月历页：Canvas 月历热力视图 + 月份切换 + 选中日期明细
 */
@Component
export struct HistoryPage {
  @StorageLink('dataVersion') @Watch('onReload') dataVersion: number = 0;
  @State viewYear: number = 2026;
  @State viewMonth: number = 0;
  @State heatData: number[] = [];
  @State selectedDay: number = 1;
  @State periodRecords: PeriodRecords = new PeriodRecords();
  @State dayRecords: DailyRecord[] = [];
  @State monthFeedCount: number = 0;
  @State monthDiaperCount: number = 0;
  @State monthSleepMs: number = 0;
  @State monthGrowthCount: number = 0;

  aboutToAppear(): void {
    const now = new Date();
    this.viewYear = now.getFullYear();
    this.viewMonth = now.getMonth();
    this.selectedDay = now.getDate();
    this.loadMonth();
  }

  onReload(): void {
    this.loadMonth();
  }

  private monthStartMs(): number {
    return new Date(this.viewYear, this.viewMonth, 1).getTime();
  }

  private monthEndMs(): number {
    return new Date(this.viewYear, this.viewMonth + 1, 1).getTime();
  }

  private async loadMonth(): Promise<void> {
    try {
      const records: PeriodRecords =
        await DatabaseHelper.getInstance().queryPeriodRecords(this.monthStartMs(), this.monthEndMs());
      this.periodRecords = records;
      this.rebuildStats(records);
      this.loadSelectedDay(records);
    } catch (e) {
      console.error('HistoryPage loadMonth failed: ' + e);
    }
  }

  private rebuildStats(records: PeriodRecords): void {
    const days = TimeUtils.daysInMonth(this.viewYear, this.viewMonth);
    const heat: number[] = [];
    for (let i = 0; i < days; i++) {
      heat.push(0);
    }
    this.monthFeedCount = records.feeds.length;
    this.monthDiaperCount = records.diapers.length;
    this.monthSleepMs = DatabaseHelper.calcTotalSleepMs(records.sleeps);
    this.monthGrowthCount = records.growth.length;

    const addHeat = (timeMs: number) => {
      const dayStart = TimeUtils.dayStart(timeMs);
      const idx = Math.floor((dayStart - this.monthStartMs()) / TimeUtils.DAY);
      if (idx >= 0 && idx < heat.length) {
        heat[idx] = heat[idx] + 1;
      }
    };
    for (let i = 0; i < records.feeds.length; i++) {
      addHeat(records.feeds[i].startTime);
    }
    for (let i = 0; i < records.diapers.length; i++) {
      addHeat(records.diapers[i].changeTime);
    }
    for (let i = 0; i < records.sleeps.length; i++) {
      addHeat(records.sleeps[i].startTime);
    }
    for (let i = 0; i < records.growth.length; i++) {
      addHeat(records.growth[i].measureTime);
    }
    this.heatData = heat;
  }

  private loadSelectedDay(records: PeriodRecords): void {
    const dayStart = new Date(this.viewYear, this.viewMonth, this.selectedDay).getTime();
    const dayEnd = dayStart + TimeUtils.DAY;
    const filtered = new PeriodRecords();
    for (let i = 0; i < records.feeds.length; i++) {
      const r = records.feeds[i];
      if (r.startTime >= dayStart && r.startTime < dayEnd) {
        filtered.feeds.push(r);
      }
    }
    for (let i = 0; i < records.diapers.length; i++) {
      const r = records.diapers[i];
      if (r.changeTime >= dayStart && r.changeTime < dayEnd) {
        filtered.diapers.push(r);
      }
    }
    for (let i = 0; i < records.sleeps.length; i++) {
      const r = records.sleeps[i];
      if (r.startTime >= dayStart && r.startTime < dayEnd) {
        filtered.sleeps.push(r);
      }
    }
    for (let i = 0; i < records.growth.length; i++) {
      const r = records.growth[i];
      if (r.measureTime >= dayStart && r.measureTime < dayEnd) {
        filtered.growth.push(r);
      }
    }
    this.dayRecords = buildDailyRecords(filtered);
  }

  private switchMonth(delta: number): void {
    let m = this.viewMonth + delta;
    let y = this.viewYear;
    if (m < 0) {
      m = 11;
      y = y - 1;
    } else if (m > 11) {
      m = 0;
      y = y + 1;
    }
    this.viewMonth = m;
    this.viewYear = y;
    const days = TimeUtils.daysInMonth(y, m);
    if (this.selectedDay > days) {
      this.selectedDay = days;
    }
    this.loadMonth();
  }

  private async deleteRecord(kind: string, recordId: number): Promise<void> {
    const db = DatabaseHelper.getInstance();
    if (kind === 'feed') {
      await db.deleteFeed(recordId);
    } else if (kind === 'diaper') {
      await db.deleteDiaper(recordId);
    } else if (kind === 'sleep') {
      await db.deleteSleep(recordId);
    } else if (kind === 'growth') {
      await db.deleteGrowth(recordId);
    }
    this.dataVersion++;
  }

  private monthTitle(): string {
    return this.viewYear + '年' + (this.viewMonth + 1) + '月';
  }

  private selectedDateText(): string {
    return this.viewYear + '-' + (this.viewMonth + 1) + '-' + this.selectedDay;
  }

  private monthSummaryText(): string {
    return '喂养 ' + this.monthFeedCount + ' 次 · 尿布 ' + this.monthDiaperCount + ' 次 · 睡眠 '
      + TimeUtils.formatDurationShort(this.monthSleepMs) + ' · 成长 ' + this.monthGrowthCount + ' 次';
  }

  build() {
    Scroll() {
      Column() {
        // 月份切换
        Row() {
          Text('‹')
            .fontSize(22)
            .fontColor(Theme.TEXT)
            .width(40)
            .height(40)
            .textAlign(TextAlign.Center)
            .backgroundColor(Theme.CARD)
            .borderRadius(12)
            .onClick(() => {
              this.switchMonth(-1);
            })
          Blank()
          Column() {
            Text(this.monthTitle())
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.TEXT)
            Text(this.monthSummaryText())
              .fontSize(11)
              .fontColor(Theme.TEXT_SUB)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Center)
          Blank()
          Text('›')
            .fontSize(22)
            .fontColor(Theme.TEXT)
            .width(40)
            .height(40)
            .textAlign(TextAlign.Center)
            .backgroundColor(Theme.CARD)
            .borderRadius(12)
            .onClick(() => {
              this.switchMonth(1);
            })
        }
        .width('100%')
        .margin({ top: 8, bottom: 12 })

        // 月历热力图
        Column() {
          Row() {
            Text('记录热力')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.TEXT_SUB)
            Blank()
            Text('颜色越深记录越多，点击查看当天')
              .fontSize(11)
              .fontColor(Theme.TEXT_LIGHT)
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 12 })

          CalendarHeat({
            year: this.viewYear,
            month: this.viewMonth,
            heatData: this.heatData,
            selectedDay: this.selectedDay,
            onSelectDay: (day: number) => {
              this.selectedDay = day;
              this.loadSelectedDay(this.periodRecords);
            }
          })
        }
        .width('100%')
        .backgroundColor(Theme.CARD)
        .borderRadius(16)

        // 选中日期明细
        Row() {
          Text('📅 ' + this.selectedDateText())
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT)
          Blank()
          Text(this.dayRecords.length + ' 条记录')
            .fontSize(12)
            .fontColor(Theme.TEXT_SUB)
        }
        .width('100%')
        .margin({ top: 20, bottom: 10 })

        if (this.dayRecords.length === 0) {
          Text('这一天没有记录')
            .fontSize(13)
            .fontColor(Theme.TEXT_LIGHT)
            .margin({ top: 24, bottom: 24 })
        } else {
          List() {
            ForEach(this.dayRecords, (item: DailyRecord) => {
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
