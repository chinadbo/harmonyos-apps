// 周视图页面，展示一周七天的日程概览并支持跳转到日视图
import * as router from '@ohos.router';
import common from '@ohos.app.ability.common';
import StorageManager from '../data/StorageManager';
import { EventModel } from '../models/EventModel';
import { addDays, createDateKey, filterEventsForDay, formatDate, formatTime, getStartOfWeek, getWeekDays } from '../utils/DateUtils';

@Component
struct WeekViewPage {
  @State currentDate: Date = new Date();
  @State weekDays: Date[] = [];
  @State weekEvents: EventModel[] = [];

  aboutToAppear(): void {
    const params: Record<string, number> = router.getParams() as Record<string, number>;
    if (params && params.timestamp) {
      this.currentDate = new Date(params.timestamp);
    }
    this.initializePage();
  }

  async initializePage(): Promise<void> {
    await StorageManager.initialize(getContext(this) as common.UIAbilityContext);
    await this.loadWeekData();
  }

  async loadWeekData(): Promise<void> {
    this.weekDays = getWeekDays(this.currentDate);
    const weekStart: Date = getStartOfWeek(this.currentDate);
    const weekEnd: Date = new Date(weekStart.getFullYear(), weekStart.getMonth(), weekStart.getDate() + 6, 23, 59, 59, 999);
    this.weekEvents = await StorageManager.getExpandedEventsForRange(weekStart, weekEnd);
  }

  async changeWeek(offset: number): Promise<void> {
    this.currentDate = addDays(this.currentDate, offset * 7);
    await this.loadWeekData();
  }

  getEventsForDay(day: Date): EventModel[] {
    return filterEventsForDay(this.weekEvents, day);
  }

  openDay(day: Date): void {
    router.pushUrl({
      url: 'pages/DayViewPage',
      params: {
        timestamp: day.getTime(),
        dateKey: createDateKey(day)
      }
    });
  }

  build() {
    Column({ space: 0 }) {
      Row() {
        Button('<')
          .width(40)
          .height(40)
          .backgroundColor('#FFFFFF')
          .fontColor('#182431')
          .borderRadius(20)
          .onClick(() => {
            this.changeWeek(-1);
          })
        Column({ space: 4 }) {
          Text('周视图')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
          if (this.weekDays.length > 0) {
            Text(`${formatDate(this.weekDays[0])} - ${formatDate(this.weekDays[this.weekDays.length - 1])}`)
              .fontSize(13)
              .fontColor('#5B6770')
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        Button('>')
          .width(40)
          .height(40)
          .backgroundColor('#FFFFFF')
          .fontColor('#182431')
          .borderRadius(20)
          .onClick(() => {
            this.changeWeek(1);
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 16 })

      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.weekDays, (day: Date) => {
            Column({ space: 10 }) {
              Row() {
                Text(formatDate(day))
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#182431')
                Blank()
                Text('查看日程')
                  .fontSize(12)
                  .fontColor('#4A90D9')
              }
              .width('100%')
              .onClick(() => {
                this.openDay(day);
              })

              if (this.getEventsForDay(day).length === 0) {
                Text('暂无日程')
                  .fontSize(13)
                  .fontColor('#9AA5B1')
                  .width('100%')
                  .padding(14)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(18)
              } else {
                ForEach(this.getEventsForDay(day), (event: EventModel) => {
                  Row() {
                    Column({ space: 4 }) {
                      Text(event.title)
                        .fontSize(15)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#182431')
                        .maxLines(1)
                      Text(`${formatTime(event.startTime)} - ${formatTime(event.endTime)}`)
                        .fontSize(12)
                        .fontColor('#5B6770')
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                  }
                  .width('100%')
                  .padding(14)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(18)
                  .border({ width: 0.5, color: event.color })
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/EventDetailPage',
                      params: {
                        eventId: event.id
                      }
                    });
                  })
                })
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#EEF4FB')
            .borderRadius(22)
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 24 })
      }
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FB')
  }
}
