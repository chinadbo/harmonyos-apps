import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { CalendarDayItem, CountdownEvent } from '../model/CountdownEvent';
import DatabaseService from '../service/DatabaseService';
import { DateUtils } from '../utils/DateUtils';

@Entry
@Component
struct CalendarPage {
  @State year: number = new Date().getFullYear();
  @State month: number = new Date().getMonth();
  @State days: CalendarDayItem[] = [];
  @State selectedDate: string = DateUtils.formatDate(new Date());
  @State selectedEvents: CountdownEvent[] = [];
  @State allEvents: CountdownEvent[] = [];

  async aboutToAppear(): Promise<void> {
    let context = getContext(this) as common.UIAbilityContext;
    await DatabaseService.init(context);
    this.allEvents = await DatabaseService.listEvents();
    this.refreshMonth();
  }

  refreshMonth(): void {
    this.days = DateUtils.buildMonthGrid(this.year, this.month, this.allEvents);
    this.selectedEvents = DateUtils.filterByDate(this.allEvents, this.selectedDate);
  }

  selectDay(item: CalendarDayItem): void {
    this.selectedDate = item.fullDate;
    this.selectedEvents = DateUtils.filterByDate(this.allEvents, this.selectedDate);
  }

  build() {
    Column() {
      Row() {
        Button('返回').backgroundColor('#FFFFFF').fontColor('#333333').onClick(() => {
          router.back();
        });
        Blank();
        Button('上一月').backgroundColor('#FFFFFF').fontColor('#333333').onClick(() => {
          if (this.month === 0) {
            this.year -= 1;
            this.month = 11;
          } else {
            this.month -= 1;
          }
          this.refreshMonth();
        });
        Button('下一月').margin({ left: 8 }).backgroundColor('#FF5B4D').onClick(() => {
          if (this.month === 11) {
            this.year += 1;
            this.month = 0;
          } else {
            this.month += 1;
          }
          this.refreshMonth();
        });
      }
      .padding(16);
      Text(`${this.year}年 ${this.month + 1}月`).fontSize(28).fontWeight(FontWeight.Bold).margin({ bottom: 12 });
      GridRow({ columns: 7 }) {
        ForEach(DateUtils.getWeekTitles(), (title: string) => {
          GridCol() {
            Text(title).fontSize(15).fontWeight(FontWeight.Medium).textAlign(TextAlign.Center).width('100%');
          }
        });
      }
      .padding({ left: 8, right: 8, bottom: 8 });
      GridRow({ columns: 7 }) {
        ForEach(this.days, (item: CalendarDayItem) => {
          GridCol() {
            Column({ space: 4 }) {
              Text(item.dateText)
                .fontSize(16)
                .fontColor(item.isCurrentMonth ? '#222222' : '#AAAAAA')
                .fontWeight(item.fullDate === this.selectedDate ? FontWeight.Bold : FontWeight.Regular);
              if (item.hasEvent) {
                Text(`${item.eventCount}`).fontSize(11).fontColor('#FFFFFF').backgroundColor('#FF5B4D').borderRadius(10).padding({ left: 6, right: 6, top: 2, bottom: 2 });
              } else {
                Text(' ').fontSize(11);
              }
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .height(56)
            .borderRadius(14)
            .backgroundColor(item.fullDate === this.selectedDate ? '#FFF0EE' : (item.isToday ? '#FFF8D7' : '#FFFFFF'))
            .onClick(() => {
              this.selectDay(item);
            });
          }
        }, (item: CalendarDayItem) => item.fullDate)
      }
      .padding({ left: 8, right: 8 });
      Column({ space: 10 }) {
        Row() {
          Text(DateUtils.formatDisplayDate(this.selectedDate)).fontSize(18).fontWeight(FontWeight.Bold);
          Blank();
          Text(`${this.selectedEvents.length} 个事件`).fontSize(14).fontColor('#666666');
        }
        ForEach(this.selectedEvents, (item: CountdownEvent) => {
          Row() {
            Text(item.title).fontSize(16).fontColor('#222222');
            Blank();
            Text(DateUtils.calculateDayInfo(item).displayText).fontSize(14).fontColor('#FF5B4D');
          }
          .padding(14)
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/DetailPage', params: { id: item.id } });
          });
        }, (item: CountdownEvent) => `${item.id}`)
        if (this.selectedEvents.length === 0) {
          Text('这一天没有记录事件').fontSize(14).fontColor('#888888').margin({ top: 8 });
        }
      }
      .padding(16)
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF7F7F9');
  }
}
