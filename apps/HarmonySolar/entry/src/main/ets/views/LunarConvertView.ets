import { LunarDate, LunarMonthOption, SolarDateResult } from '../model/LunarDate';
import { LunarCalendar } from '../engine/LunarCalendar';
import { Palette, Utils } from '../common/Constants';

@Component
export struct LunarConvertView {
  @State mode: number = 0;
  @State selectedDate: Date = new Date();
  @State solarLunarDay: string = '';
  @State solarGanzhi: string = '';
  @State solarZodiac: string = '';
  @State solarWeekday: string = '';
  @State lunarSolarDate: string = '';
  @State lunarDetail: string = '';
  @State yearIndex: number = 0;
  @State monthIndex: number = 0;
  @State dayIndex: number = 0;
  @State yearLabels: string[] = [];
  @State monthLabels: string[] = [];
  @State dayLabels: string[] = [];
  private years: number[] = [];
  private monthOptions: LunarMonthOption[] = [];

  aboutToAppear(): void {
    this.selectedDate = new Date();
    this.calcSolarToLunar();
    const minYear: number = LunarCalendar.minYear();
    const maxYear: number = LunarCalendar.maxYear();
    for (let y: number = minYear; y <= maxYear; y++) {
      this.years.push(y);
      this.yearLabels.push(y + '年');
    }
    this.syncLunarToToday();
  }

  private calcSolarToLunar(): void {
    const d: Date = this.selectedDate;
    const lunar: LunarDate = LunarCalendar.solarToLunar(d.getFullYear(), d.getMonth() + 1, d.getDate());
    this.solarLunarDay = lunar.monthName + lunar.dayName;
    this.solarGanzhi = lunar.ganzhiYear + '年 ' + lunar.ganzhiMonth + '月 ' + lunar.ganzhiDay + '日';
    this.solarZodiac = lunar.zodiac;
    this.solarWeekday = Utils.weekday(d);
  }

  private syncLunarToToday(): void {
    const now: Date = new Date();
    const lunar: LunarDate = LunarCalendar.solarToLunar(now.getFullYear(), now.getMonth() + 1, now.getDate());
    const idx: number = this.years.indexOf(lunar.year);
    this.yearIndex = idx >= 0 ? idx : 0;
    this.rebuildMonths(lunar.month, lunar.isLeap);
    this.rebuildDays(lunar.day);
    this.calcLunarToSolar();
  }

  private rebuildMonths(month: number, isLeap: boolean): void {
    const year: number = this.years.length > 0 ? this.years[this.yearIndex] : 0;
    const options: LunarMonthOption[] = LunarCalendar.monthOptions(year);
    let index: number = 0;
    let matched: boolean = false;
    for (let i: number = 0; i < options.length; i++) {
      if (options[i].month === month && options[i].isLeap === isLeap) {
        index = i;
        matched = true;
        break;
      }
    }
    if (!matched) {
      index = 0;
    }
    const labels: string[] = [];
    for (let i: number = 0; i < options.length; i++) {
      labels.push(options[i].label);
    }
    this.monthOptions = options;
    this.monthLabels = labels;
    this.monthIndex = index;
  }

  private rebuildDays(day: number): void {
    if (this.monthOptions.length === 0) {
      return;
    }
    const option: LunarMonthOption = this.monthOptions[this.monthIndex];
    const year: number = this.years[this.yearIndex];
    const count: number = LunarCalendar.daysInMonth(year, option.month, option.isLeap);
    const labels: string[] = [];
    for (let d: number = 1; d <= count; d++) {
      labels.push(LunarCalendar.dayLabel(d));
    }
    this.dayLabels = labels;
    const target: number = day - 1;
    this.dayIndex = target < 0 ? 0 : (target >= count ? count - 1 : target);
  }

  private calcLunarToSolar(): void {
    if (this.monthOptions.length === 0) {
      return;
    }
    const year: number = this.years[this.yearIndex];
    const option: LunarMonthOption = this.monthOptions[this.monthIndex];
    const day: number = this.dayIndex + 1;
    const solar: SolarDateResult = LunarCalendar.lunarToSolar(year, option.month, day, option.isLeap);
    this.lunarSolarDate = solar.year + '年' + solar.month + '月' + solar.day + '日';
    const ganzhiDay: string = LunarCalendar.dayGanZhi(solar.year, solar.month, solar.day);
    this.lunarDetail = solar.weekday + ' · ' + LunarCalendar.yearGanZhi(year) + '年 ' +
      LunarCalendar.monthGanZhi(year, option.month) + '月 ' + ganzhiDay + '日 · 属' +
      LunarCalendar.zodiac(year);
  }

  private onYearChange(index: number): void {
    if (index < 0 || index >= this.years.length) {
      return;
    }
    const previous: LunarMonthOption | undefined = this.monthOptions[this.monthIndex];
    const prevMonth: number = previous === undefined ? 1 : previous.month;
    const prevLeap: boolean = previous === undefined ? false : previous.isLeap;
    const prevDay: number = this.dayIndex + 1;
    this.yearIndex = index;
    this.rebuildMonths(prevMonth, prevLeap);
    this.rebuildDays(prevDay);
    this.calcLunarToSolar();
  }

  private onMonthChange(index: number): void {
    if (index < 0 || index >= this.monthOptions.length) {
      return;
    }
    const prevDay: number = this.dayIndex + 1;
    this.monthIndex = index;
    this.rebuildDays(prevDay);
    this.calcLunarToSolar();
  }

  private onDayChange(index: number): void {
    if (index < 0 || index >= this.dayLabels.length) {
      return;
    }
    this.dayIndex = index;
    this.calcLunarToSolar();
  }

  private resetToday(): void {
    this.selectedDate = new Date();
    this.calcSolarToLunar();
    this.syncLunarToToday();
  }

  @Builder
  ModeButton(label: string, value: number) {
    Text(label)
      .fontSize(13)
      .fontWeight(this.mode === value ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.mode === value ? Color.White : Palette.INK_SOFT)
      .backgroundColor(this.mode === value ? Palette.INK : Color.Transparent)
      .borderRadius(16)
      .padding({ left: 18, right: 18, top: 7, bottom: 7 })
      .onClick(() => {
        this.mode = value;
      })
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(11)
        .fontColor(Palette.INK_FAINT)
        .width(52)
      Text(value)
        .fontSize(13)
        .fontColor(Palette.INK)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding({ top: 3, bottom: 3 })
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Row() {
          Column({ space: 4 }) {
            Text('历法换算')
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.INK)
            Text('公历 / 农历 · 天干地支 · 生肖')
              .fontSize(10)
              .letterSpacing(1)
              .fontColor(Palette.INK_FAINT)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text('历')
            .fontSize(18)
            .fontColor(Palette.SEAL_RED)
            .width(40)
            .height(40)
            .textAlign(TextAlign.Center)
            .border({ width: 2, color: Palette.SEAL_RED })
            .borderRadius(6)
        }
        .width('100%')
        .padding({ top: 4, bottom: 2 })

        Row({ space: 4 }) {
          this.ModeButton('公历 → 农历', 0)
          this.ModeButton('农历 → 公历', 1)
          Blank()
          Text('今天')
            .fontSize(11)
            .fontColor(Palette.GOLD)
            .border({ width: 1, color: Palette.GOLD })
            .borderRadius(14)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .onClick(() => {
              this.resetToday();
            })
        }
        .width('100%')
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })
        .borderRadius(20)
        .backgroundColor('#F3EBDD')

        if (this.mode === 0) {
          Column({ space: 8 }) {
            Row() {
              Text('选择公历日期')
                .fontSize(11)
                .letterSpacing(1)
                .fontColor(Palette.INK_SOFT)
              Blank()
              Text(this.selectedDate.getFullYear() + ' 年')
                .fontSize(11)
                .fontColor(Utils.seasonColor('秋'))
            }
            .width('100%')

            DatePicker({
              start: new Date(1901, 0, 1),
              end: new Date(2099, 11, 31),
              selected: this.selectedDate
            })
              .lunar(false)
              .width('100%')
              .height(190)
              .onDateChange((value: Date) => {
                this.selectedDate = value;
                this.calcSolarToLunar();
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Palette.CARD_BG)
          .borderRadius(20)
          .border({ width: 1, color: '#F2EBDD' })

          Column({ space: 10 }) {
            Row() {
              Column({ space: 3 }) {
                Text('对应农历')
                  .fontSize(10)
                  .letterSpacing(2)
                  .fontColor(Palette.INK_FAINT)
                Text(this.solarLunarDay)
                  .fontSize(30)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Palette.INK)
                  .letterSpacing(2)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Column({ space: 1 }) {
                Text('属' + this.solarZodiac)
                  .fontSize(16)
                  .fontColor(Palette.SEAL_RED)
                Text('ZODIAC')
                  .fontSize(6)
                  .letterSpacing(1)
                  .fontColor(Palette.SEAL_RED)
              }
              .width(54)
              .height(54)
              .justifyContent(FlexAlign.Center)
              .border({ width: 2, color: Palette.SEAL_RED })
              .borderRadius(6)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            Divider().color('#EFE6D5')

            this.InfoRow('公历', Utils.fullDate(this.selectedDate) + ' ' + this.solarWeekday)
            this.InfoRow('农历', '农历' + this.solarLunarDay)
            this.InfoRow('干支', this.solarGanzhi)
            this.InfoRow('生肖', this.solarZodiac + '年')

            Text('公历日期在界面滚动选择，农历结果实时换算。')
              .fontSize(10)
              .fontColor(Palette.INK_FAINT)
              .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(18)
          .backgroundColor(Utils.seasonSoft('春'))
          .borderRadius(20)
          .border({ width: 1, color: '#E2ECDF' })
        } else {
          Column({ space: 10 }) {
            Row() {
              Text('选择农历日期')
                .fontSize(11)
                .letterSpacing(1)
                .fontColor(Palette.INK_SOFT)
              Blank()
              Text(this.monthLabels.length > 0 ? this.monthLabels[this.monthIndex] : '')
                .fontSize(11)
                .fontColor(Utils.seasonColor('夏'))
            }
            .width('100%')

            Row({ space: 6 }) {
              Text('年')
                .fontSize(10)
                .fontColor(Palette.INK_FAINT)
                .width(16)
                .textAlign(TextAlign.Center)
              Text('月')
                .fontSize(10)
                .fontColor(Palette.INK_FAINT)
                .width(16)
                .textAlign(TextAlign.Center)
              Text('日')
                .fontSize(10)
                .fontColor(Palette.INK_FAINT)
                .width(16)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)

            Row({ space: 2 }) {
              TextPicker({ range: this.yearLabels, selected: this.yearIndex })
                .layoutWeight(1)
                .height(170)
                .onChange((value: string | string[], index: number | number[]) => {
                  this.onYearChange(index as number);
                })
              TextPicker({ range: this.monthLabels, selected: this.monthIndex })
                .layoutWeight(1)
                .height(170)
                .onChange((value: string | string[], index: number | number[]) => {
                  this.onMonthChange(index as number);
                })
              TextPicker({ range: this.dayLabels, selected: this.dayIndex })
                .layoutWeight(1)
                .height(170)
                .onChange((value: string | string[], index: number | number[]) => {
                  this.onDayChange(index as number);
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Palette.CARD_BG)
          .borderRadius(20)
          .border({ width: 1, color: '#F2EBDD' })

          Column({ space: 10 }) {
            Column({ space: 3 }) {
              Text('对应公历')
                .fontSize(10)
                .letterSpacing(2)
                .fontColor(Palette.INK_FAINT)
              Text(this.lunarSolarDate)
                .fontSize(27)
                .fontWeight(FontWeight.Medium)
                .fontColor(Palette.INK)
                .letterSpacing(1)
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            Divider().color('#EFE6D5')

            this.InfoRow('农历', (this.monthLabels.length > 0 ?
              LunarCalendar.yearGanZhi(this.years.length > 0 ? this.years[this.yearIndex] : 0) + '年 ' +
                this.monthLabels[this.monthIndex] : '') + ' ' +
              (this.dayLabels.length > 0 ? this.dayLabels[this.dayIndex] : ''))
            this.InfoRow('详情', this.lunarDetail)

            Text('支持 1901—2099 年农历换算，闰月以「闰 X 月」标注。')
              .fontSize(10)
              .fontColor(Palette.INK_FAINT)
              .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(18)
          .backgroundColor(Utils.seasonSoft('秋'))
          .borderRadius(20)
          .border({ width: 1, color: '#EFE3C8' })
        }

        Column({ space: 6 }) {
          Text('算法说明')
            .fontSize(10)
            .letterSpacing(2)
            .fontColor(Palette.GOLD)
          Text('农历采用 1900—2100 年历表，依朔望月与闰月规则推算天干地支；节气交节时刻取自内置 2026—2027 年天文数据，全部离线计算。')
            .fontSize(11)
            .lineHeight(19)
            .fontColor(Palette.INK_SOFT)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(16)
        .backgroundColor('#F7F1E6')
        .borderRadius(18)

        Row()
          .width('100%')
          .height(80)
      }
      .padding({ left: 18, right: 18, top: 14 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(Palette.PAGE_BG)
  }
}
