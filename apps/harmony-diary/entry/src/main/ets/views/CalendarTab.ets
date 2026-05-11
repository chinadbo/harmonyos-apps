import common from '@ohos.app.ability.common';
import { DiaryListItem } from '../model/DiaryModel';
import { diaryRepository } from '../service/DiaryRepository';
import { MonthCalendar } from '../components/MonthCalendar';
import { DiaryCard } from '../components/DiaryCard';
import { EmptyState } from '../components/EmptyState';
import { buildCalendarDays, monthTitle, nextMonth, previousMonth, todayKey } from '../utils/DateUtils';

@Component
export struct CalendarTab {
  @StorageLink('diary_refresh_token') @Watch('reloadMonth') refreshToken: number = 0;
  navPathStack?: NavPathStack;
  @State year: number = new Date().getFullYear();
  @State month: number = new Date().getMonth() + 1;
  @State entries: DiaryListItem[] = [];
  @State selectedDate: string = todayKey();
  // P1 Fix: build() 内不能用 const，将计算属性提升为 @State，由 selectedDate/entries 变化时更新
  @State selectedEntries: DiaryListItem[] = [];

  aboutToAppear(): void {
    this.reloadMonth();
  }

  private context(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext;
  }

  async reloadMonth(): Promise<void> {
    this.entries = await diaryRepository.getEntriesByMonth(this.context(), this.year, this.month);
    this.updateSelectedEntries();
  }

  private updateSelectedEntries(): void {
    this.selectedEntries = this.entries.filter((item: DiaryListItem) => item.date === this.selectedDate);
  }

  private changeMonth(offset: number): void {
    let values: [number, number];
    if (offset < 0) {
      values = previousMonth(this.year, this.month);
    } else {
      values = nextMonth(this.year, this.month);
    }
    this.year = values[0];
    this.month = values[1];
    this.reloadMonth();
  }

  private openDate(dateKey: string, hasEntry: boolean): void {
    this.selectedDate = dateKey;
    this.updateSelectedEntries();
    if (hasEntry) {
      const record = this.entries.find((item: DiaryListItem) => item.date === dateKey);
      if (record) {
        this.navPathStack?.pushPath({ name: 'DiaryDetail', param: { id: record.id } });
      }
      return;
    }
    this.navPathStack?.pushPath({ name: 'DiaryEditor', param: { date: dateKey } });
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Button('‹')
            .width(40)
            .height(40)
            .backgroundColor('#F1F5F9')
            .fontColor('#0F172A')
            .onClick(() => this.changeMonth(-1))
          Blank()
          Text(monthTitle(this.year, this.month))
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
          Blank()
          Button('›')
            .width(40)
            .height(40)
            .backgroundColor('#F1F5F9')
            .fontColor('#0F172A')
            .onClick(() => this.changeMonth(1))
        }
        .width('100%')

        Column({ space: 16 }) {
          MonthCalendar({
            days: buildCalendarDays(this.year, this.month, this.entries),
            onSelectDay: (dateKey: string, hasEntry: boolean) => this.openDate(dateKey, hasEntry)
          })
        }
        .width('100%')
        .padding(18)
        .backgroundColor('#FFFFFF')
        .borderRadius(28)
        .shadow({ radius: 16, color: '#120F172A', offsetX: 0, offsetY: 8 })

        Column({ space: 12 }) {
          Text(`${this.selectedDate} 的记录`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#0F172A')
            .width('100%')
          if (this.selectedEntries.length === 0) {
            EmptyState({ title: '这一天还没有日记', message: '点选日期后可以立即开始写。' })
          } else {
            ForEach(this.selectedEntries, (item: DiaryListItem) => {
              DiaryCard({ item, onClick: (id: number) => this.navPathStack?.pushPath({ name: 'DiaryDetail', param: { id } }) })
            })
          }
        }
        .width('100%')
      }
      .padding(20)
      .alignItems(HorizontalAlign.Start)
    }
    .scrollBar(BarState.Off)
  }
}
