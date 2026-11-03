import { Theme } from '../model/Theme';
import { RdbHelper, RecordRow } from '../data/RdbHelper';
import { PreferencesUtil } from '../data/PreferencesUtil';
import { BarChartComponent } from '../components/BarChartComponent';
import { daysBeforeYMD, todayYMD, monthStartWeekday, monthDayCount, ymdString, weekdayChar } from '../utils/DateUtil';

interface CalendarCell {
  day: number;
  date: string;
  placeholder: boolean;
}

@Entry
@Component
struct StatsPage {
  @State weekValues: number[] = [];
  @State weekRates: number[] = [];
  @State weekLabels: string[] = [];
  @State calendarRows: CalendarCell[][] = [];
  @State practicedDates: string[] = [];
  @State totalRounds: number = 0;
  @State totalQuestions: number = 0;
  @State totalCorrect: number = 0;
  @State streakDays: number = 0;
  @State dailyGoal: number = 20;
  @State loading: boolean = true;
  private monthTitle: string = '';

  aboutToAppear(): void {
    this.load();
  }

  onPageShow(): void {
    this.load();
  }

  private async load(): Promise<void> {
    this.loading = true;
    const rdb: RdbHelper = RdbHelper.getInstance();
    await rdb.ready();
    const rows: RecordRow[] = await rdb.queryRecordRows();

    this.totalRounds = rows.length;
    let totalQ: number = 0;
    let totalC: number = 0;
    const dates: string[] = [];
    for (const row of rows) {
      totalQ += row.total;
      totalC += row.correct;
      if (dates.indexOf(row.date) < 0) {
        dates.push(row.date);
      }
    }
    this.totalQuestions = totalQ;
    this.totalCorrect = totalC;
    this.practicedDates = dates;

    const values: number[] = [];
    const rates: number[] = [];
    const labels: string[] = [];
    for (let i: number = 6; i >= 0; i--) {
      const dateStr: string = daysBeforeYMD(i);
      let dayTotal: number = 0;
      let dayCorrect: number = 0;
      for (const row of rows) {
        if (row.date === dateStr) {
          dayTotal += row.total;
          dayCorrect += row.correct;
        }
      }
      values.push(dayTotal);
      rates.push(dayTotal > 0 ? Math.round(dayCorrect * 100 / dayTotal) : 0);
      labels.push(i === 0 ? '今天' : `周${weekdayChar(Date.now() - i * 86400000)}`);
    }
    this.weekValues = values;
    this.weekRates = rates;
    this.weekLabels = labels;

    this.buildCalendar();

    const prefs: PreferencesUtil = PreferencesUtil.getInstance();
    await prefs.ready();
    this.streakDays = await prefs.getStreakDays();
    this.dailyGoal = await prefs.getDailyGoal();
    this.loading = false;
  }

  private buildCalendar(): void {
    const now: Date = new Date();
    const year: number = now.getFullYear();
    const month: number = now.getMonth() + 1;
    const nowMs: number = Date.now();
    const firstWeekday: number = monthStartWeekday(nowMs);
    const dayCount: number = monthDayCount(nowMs);
    const cells: CalendarCell[] = [];
    for (let i: number = 0; i < firstWeekday; i++) {
      const cell: CalendarCell = { day: 0, date: '', placeholder: true };
      cells.push(cell);
    }
    for (let day: number = 1; day <= dayCount; day++) {
      const cell: CalendarCell = { day: day, date: ymdString(year, month, day), placeholder: false };
      cells.push(cell);
    }
    while (cells.length % 7 !== 0) {
      const cell: CalendarCell = { day: 0, date: '', placeholder: true };
      cells.push(cell);
    }
    const rows: CalendarCell[][] = [];
    for (let i: number = 0; i < cells.length; i += 7) {
      const week: CalendarCell[] = [];
      for (let j: number = 0; j < 7; j++) {
        week.push(cells[i + j]);
      }
      rows.push(week);
    }
    this.calendarRows = rows;
    this.monthTitle = `${year} 年 ${month} 月`;
  }

  build() {
    Column({ space: 14 }) {
      if (this.loading) {
        Column({ space: 12 }) {
          LoadingProgress()
            .width(48)
            .height(48)
            .color(Theme.PRIMARY)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 14 }) {
            Text($r('app.string.title_stats'))
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.TEXT_DARK)
              .width('100%')

            Row({ space: 10 }) {
              this.StatCell(`${this.totalRounds}`, '累计轮数')
              this.StatCell(`${this.totalQuestions}`, '累计题数')
              this.StatCell(`${this.totalAccuracy()}%`, '总正确率')
            }
            .width('100%')

            Row({ space: 10 }) {
              this.StatCell(`${this.streakDays}`, '连续打卡')
              this.StatCell(`${this.dailyGoal}`, '每日目标')
              this.StatCell(`${this.practicedDates.length}`, '练习天数')
            }
            .width('100%')

            Column({ space: 8 }) {
              Text('近 7 天练习量与正确率')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.TEXT_DARK)
                .width('100%')
              BarChartComponent({
                values: this.weekValues,
                rates: this.weekRates,
                labels: this.weekLabels
              })
              Row({ space: 12 }) {
                Row({ space: 4 }) {
                  Circle({ width: 8, height: 8 })
                    .fill(Theme.PRIMARY)
                  Text('练习题量')
                    .fontSize(11)
                    .fontColor(Theme.TEXT_SECONDARY)
                }
                Row({ space: 4 }) {
                  Circle({ width: 8, height: 8 })
                    .fill(Theme.WARNING)
                  Text('正确率')
                    .fontSize(11)
                    .fontColor(Theme.TEXT_SECONDARY)
                }
              }
            }
            .width('100%')
            .padding(14)
            .borderRadius(16)
            .backgroundColor(Color.White)

            Column({ space: 10 }) {
              Text(`打卡日历 · ${this.monthTitle}`)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.TEXT_DARK)
                .width('100%')

              Row() {
                ForEach(['日', '一', '二', '三', '四', '五', '六'], (w: string) => {
                  Text(w)
                    .fontSize(12)
                    .fontColor(Theme.TEXT_SECONDARY)
                    .layoutWeight(1)
                    .textAlign(TextAlign.Center)
                }, (w: string) => w)
              }
              .width('100%')

              ForEach(this.calendarRows, (week: CalendarCell[], rowIndex: number) => {
                Row() {
                  ForEach(week, (cell: CalendarCell) => {
                    this.CalendarCellView(cell)
                  }, (cell: CalendarCell) => `${rowIndex}_${cell.day}_${cell.date}`)
                }
                .width('100%')
                .margin({ top: 4 })
              }, (week: CalendarCell[], rowIndex: number) => `row_${rowIndex}`)
            }
            .width('100%')
            .padding(14)
            .borderRadius(16)
            .backgroundColor(Color.White)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.TopStart)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  StatCell(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.TEXT_DARK)
      Text(label)
        .fontSize(11)
        .fontColor(Theme.TEXT_SECONDARY)
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .borderRadius(12)
    .backgroundColor(Color.White)
  }

  @Builder
  CalendarCellView(cell: CalendarCell) {
    Column() {
      if (!cell.placeholder) {
        Text(`${cell.day}`)
          .fontSize(13)
          .fontColor(this.isPracticed(cell.date) ? Color.White : Theme.TEXT_DARK)
          .width(34)
          .height(34)
          .textAlign(TextAlign.Center)
          .borderRadius(17)
          .backgroundColor(this.isPracticed(cell.date) ? Theme.PRIMARY : Theme.KEY_BG)
          .border(this.isToday(cell.date) ? { width: 2, color: Theme.WARNING } : { width: 0, color: Color.Transparent })
      } else {
        Text('')
          .width(34)
          .height(34)
      }
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  private isPracticed(date: string): boolean {
    return this.practicedDates.indexOf(date) >= 0;
  }

  private isToday(date: string): boolean {
    return date === todayYMD();
  }

  private totalAccuracy(): number {
    if (this.totalQuestions <= 0) {
      return 0;
    }
    return Math.round(this.totalCorrect * 100 / this.totalQuestions);
  }
}
