// 日视图页面，按时间线展示当天日程并支持快速创建
import * as router from '@ohos.router';
import common from '@ohos.app.ability.common';
import StorageManager from '../data/StorageManager';
import { EventModel } from '../models/EventModel';
import { DEFAULT_EVENT_DURATION_MS } from '../utils/Constants';
import { HourSlot, addDays, filterEventsForDay, formatDate, formatTime, getHourSlots } from '../utils/DateUtils';

@Component
struct DayEventCard {
  @Prop event: EventModel;

  build() {
    Column({ space: 6 }) {
      Text(this.event.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .maxLines(1)
      Text(`${formatTime(this.event.startTime)} - ${formatTime(this.event.endTime)}`)
        .fontSize(12)
        .fontColor('#5B6770')
      if (this.event.location.length > 0) {
        Text(this.event.location)
          .fontSize(12)
          .fontColor('#5B6770')
          .maxLines(1)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(14)
    .backgroundColor(this.event.color)
    .borderRadius(18)
  }
}

@Component
struct DayViewPage {
  @State currentDate: Date = new Date();
  @State hourSlots: HourSlot[] = [];
  @State dayEvents: EventModel[] = [];

  aboutToAppear(): void {
    const params: Record<string, number> = router.getParams() as Record<string, number>;
    if (params && params.timestamp) {
      this.currentDate = new Date(params.timestamp);
    }
    this.initializePage();
  }

  async initializePage(): Promise<void> {
    await StorageManager.initialize(getContext(this) as common.UIAbilityContext);
    await this.loadData();
  }

  async loadData(): Promise<void> {
    this.hourSlots = getHourSlots(this.currentDate);
    const events: EventModel[] = await StorageManager.getExpandedEventsForRange(
      new Date(this.currentDate.getFullYear(), this.currentDate.getMonth(), this.currentDate.getDate(), 0, 0, 0, 0),
      new Date(this.currentDate.getFullYear(), this.currentDate.getMonth(), this.currentDate.getDate(), 23, 59, 59, 999)
    );
    this.dayEvents = filterEventsForDay(events, this.currentDate);
  }

  async changeDay(offset: number): Promise<void> {
    this.currentDate = addDays(this.currentDate, offset);
    await this.loadData();
  }

  openEvent(eventId: number): void {
    router.pushUrl({
      url: 'pages/EventDetailPage',
      params: {
        eventId
      }
    });
  }

  createFromHour(hour: number): void {
    const startTime: number = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth(), this.currentDate.getDate(), hour, 0, 0, 0).getTime();
    router.pushUrl({
      url: 'pages/EventDetailPage',
      params: {
        startTime,
        endTime: startTime + DEFAULT_EVENT_DURATION_MS
      }
    });
  }

  getEventsForHour(hour: number): EventModel[] {
    return this.dayEvents.filter((event: EventModel) => {
      const eventDate: Date = new Date(event.startTime);
      return eventDate.getHours() === hour || (eventDate.getHours() < hour && new Date(event.endTime).getHours() >= hour);
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
            this.changeDay(-1);
          })

        Column({ space: 4 }) {
          Text('日视图')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
          Text(formatDate(this.currentDate))
            .fontSize(14)
            .fontColor('#5B6770')
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
            this.changeDay(1);
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 16 })

      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.hourSlots, (slot: HourSlot) => {
            Row({ space: 12 }) {
              Text(slot.label)
                .width(56)
                .fontSize(13)
                .fontColor('#5B6770')

              Column({ space: 8 }) {
                if (this.getEventsForHour(slot.hour).length === 0) {
                  Text('长按创建日程')
                    .fontSize(12)
                    .fontColor('#9AA5B1')
                    .width('100%')
                    .padding({ top: 18, bottom: 18, left: 12, right: 12 })
                    .backgroundColor('#FFFFFF')
                    .borderRadius(18)
                    .onLongPress(() => {
                      this.createFromHour(slot.hour);
                    })
                } else {
                  ForEach(this.getEventsForHour(slot.hour), (event: EventModel) => {
                    DayEventCard({ event })
                      .onClick(() => {
                        this.openEvent(event.id);
                      })
                  })
                }
              }
              .layoutWeight(1)
            }
            .width('100%')
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
