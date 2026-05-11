import { CalendarDay } from '../model/DiaryModel';
import { getMoodOption } from '../utils/MoodConfig';

@Component
export struct MonthCalendar {
  @Prop days: CalendarDay[] = [];
  onSelectDay: (dateKey: string, hasEntry: boolean) => void = () => {};
  private readonly weeks: string[] = ['一', '二', '三', '四', '五', '六', '日'];

  build() {
    Column({ space: 12 }) {
      GridRow({ columns: 7 }) {
        ForEach(this.weeks, (week: string) => {
          GridCol({ span: 1 }) {
            Text(week)
              .width('100%')
              .textAlign(TextAlign.Center)
              .fontSize(12)
              .fontColor('#64748B')
          }
        })
      }

      GridRow({ columns: 7 }) {
        ForEach(this.days, (day: CalendarDay) => {
          GridCol({ span: 1 }) {
            Column({ space: 8 }) {
              Text(`${day.label}`)
                .fontSize(14)
                .fontWeight(day.isToday ? FontWeight.Bold : FontWeight.Regular)
                .fontColor(day.inCurrentMonth ? '#0F172A' : '#CBD5E1')
              if (day.hasEntry && day.mood) {
                Text(getMoodOption(day.mood).icon)
                  .fontSize(14)
              } else {
                Text('·')
                  .fontSize(14)
                  .fontColor(day.inCurrentMonth ? '#E2E8F0' : '#F1F5F9')
              }
            }
            .width('100%')
            .aspectRatio(1)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(day.isToday ? '#E0F2FE' : (day.hasEntry ? '#F8FAFC' : '#FFFFFF'))
            .borderRadius(18)
            .opacity(day.inCurrentMonth ? 1 : 0.45)
            .onClick(() => this.onSelectDay(day.key, day.hasEntry))
          }
        })
      }
      .gutter({ x: 8, y: 8 })
    }
    .width('100%')
  }
}
