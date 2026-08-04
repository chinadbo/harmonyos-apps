// 首页月视图，展示月历、底部导航和快捷新建入口
import * as router from '@ohos.router';
import common from '@ohos.app.ability.common';
import StorageManager from '../data/StorageManager';
import { EventModel } from '../models/EventModel';
import { TAB_INDEX_MONTH, TAB_INDEX_SETTINGS, TAB_INDEX_TAG, TAB_INDEX_WEEK } from '../utils/Constants';
import { CalendarDay, addMonths, createDateKey, formatMonthTitle, getMonthDays } from '../utils/DateUtils';

@Component
struct CalendarDayCell {
  @Prop day: CalendarDay;
  @Prop eventCount: number;
  @Link selectedDateKey: string;

  build() {
    Column({ space: 6 }) {
      Text(`${this.day.dayOfMonth}`)
        .fontSize(16)
        .fontWeight(this.day.isToday ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(this.day.isCurrentMonth ? '#182431' : '#9AA5B1')

      if (this.eventCount > 0) {
        Row({ space: 4 }) {
          ForEach(Array.from({ length: Math.min(this.eventCount, 3) }), (_: Object, index: number) => {
            Circle()
              .width(6)
              .height(6)
              .fill('#4A90D9')
          })
        }
      } else {
        Blank()
          .height(6)
      }
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(64)
    .backgroundColor(this.selectedDateKey === this.day.dateKey ? '#E8F3FF' : '#FFFFFF')
    .borderRadius(16)
    .opacity(this.day.isCurrentMonth ? 1 : 0.65)
    .border({ width: this.day.isToday ? 1.5 : 0.5, color: this.day.isToday ? '#4A90D9' : '#E6EAF0' })
    .onClick(() => {
      this.selectedDateKey = this.day.dateKey;
    })
  }
}

@Entry
@Component
struct HomePage {
  private readonly weekDayLabels: string[] = ['日', '一', '二', '三', '四', '五', '六'];
  @State currentMonth: Date = new Date();
  @State calendarDays: CalendarDay[] = [];
  @State monthEvents: EventModel[] = [];
  @State selectedDateKey: string = createDateKey(new Date());
  @State selectedTabIndex: number = TAB_INDEX_MONTH;

  aboutToAppear(): void {
    AppStorage.SetOrCreate('defaultReminderMinutes', 15);
    AppStorage.SetOrCreate('lastExportJson', '');
    this.initializePage();
  }

  async initializePage(): Promise<void> {
    await StorageManager.initialize(getContext(this) as common.UIAbilityContext);
    await this.loadMonthData();
  }

  async loadMonthData(): Promise<void> {
    this.calendarDays = getMonthDays(this.currentMonth);
    this.monthEvents = await StorageManager.getEventsForMonth(this.currentMonth);
  }

  async changeMonth(offset: number): Promise<void> {
    this.currentMonth = addMonths(this.currentMonth, offset);
    await this.loadMonthData();
  }

  getEventCount(day: CalendarDay): number {
    return this.monthEvents.filter((event: EventModel) => createDateKey(new Date(event.startTime)) === day.dateKey).length;
  }

  navigateToDay(day: CalendarDay): void {
    this.selectedDateKey = day.dateKey;
    router.pushUrl({
      url: 'pages/DayViewPage',
      params: {
        timestamp: day.date.getTime(),
        dateKey: day.dateKey
      }
    });
  }

  navigateToCreate(): void {
    router.pushUrl({
      url: 'pages/EventDetailPage',
      params: {
        dateKey: this.selectedDateKey,
        startTime: new Date().getTime(),
        endTime: new Date().getTime() + 60 * 60 * 1000
      }
    });
  }

  switchTab(index: number): void {
    this.selectedTabIndex = index;
    if (index === TAB_INDEX_WEEK) {
      router.pushUrl({ url: 'pages/WeekViewPage', params: { timestamp: this.currentMonth.getTime() } });
      return;
    }
    if (index === TAB_INDEX_TAG) {
      router.pushUrl({ url: 'pages/TagManagePage' });
      return;
    }
    if (index === TAB_INDEX_SETTINGS) {
      router.pushUrl({ url: 'pages/SettingsPage' });
    }
  }

  build() {
    Column() {
      Column({ space: 16 }) {
        Row() {
          Column({ space: 4 }) {
            Text('HarmonySchedule')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#182431')
            Text('智能管理你的每一天')
              .fontSize(14)
              .fontColor('#5B6770')
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Row({ space: 12 }) {
            Button('<')
              .width(44)
              .height(44)
              .fontColor('#182431')
              .backgroundColor('#FFFFFF')
              .borderRadius(22)
              .onClick(() => {
                this.changeMonth(-1);
              })
            Button('>')
              .width(44)
              .height(44)
              .fontColor('#182431')
              .backgroundColor('#FFFFFF')
              .borderRadius(22)
              .onClick(() => {
                this.changeMonth(1);
              })
          }
        }
        .width('100%')

        Text(formatMonthTitle(this.currentMonth))
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
          .width('100%')

        Row() {
          ForEach(this.weekDayLabels, (label: string) => {
            Text(label)
              .width('14.28%')
              .textAlign(TextAlign.Center)
              .fontSize(13)
              .fontColor('#5B6770')
          })
        }
        .width('100%')
        .padding({ top: 8, bottom: 4 })

        Column({ space: 8 }) {
          ForEach([0, 1, 2, 3, 4, 5], (rowIndex: number) => {
            Row({ space: 8 }) {
              ForEach(this.calendarDays.slice(rowIndex * 7, rowIndex * 7 + 7), (day: CalendarDay) => {
                Stack() {
                  CalendarDayCell({
                    day,
                    eventCount: this.getEventCount(day),
                    selectedDateKey: $selectedDateKey
                  })
                }
                .layoutWeight(1)
                .onClick(() => {
                  this.navigateToDay(day);
                })
              })
            }
            .width('100%')
          })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 20 })
      .layoutWeight(1)

      Row() {
        this.buildTabItem('月视图', TAB_INDEX_MONTH)
        this.buildTabItem('周视图', TAB_INDEX_WEEK)
        this.buildTabItem('标签管理', TAB_INDEX_TAG)
        this.buildTabItem('设置', TAB_INDEX_SETTINGS)
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 10, bottom: 18 })
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 24, topRight: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FB')
    .overlay(this.buildFab(), { align: Alignment.BottomEnd, offset: { x: -24, y: -90 } })
  }

  @Builder
  buildTabItem(label: string, index: number) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(13)
        .fontWeight(this.selectedTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.selectedTabIndex === index ? '#4A90D9' : '#5B6770')
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .borderRadius(16)
    .backgroundColor(this.selectedTabIndex === index ? '#E8F3FF' : '#FFFFFF')
    .onClick(() => {
      this.switchTab(index);
    })
  }

  @Builder
  buildFab() {
    Button('+')
      .width(56)
      .height(56)
      .fontSize(28)
      .fontColor('#FFFFFF')
      .backgroundColor('#4A90D9')
      .borderRadius(28)
      .shadow({ radius: 12, color: '#33000000', offsetX: 0, offsetY: 8 })
      .onClick(() => {
        this.navigateToCreate();
      })
  }
}
