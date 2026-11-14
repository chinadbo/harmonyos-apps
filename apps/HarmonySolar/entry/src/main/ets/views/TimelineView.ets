import { SolarTerm, TimelineItem, emptySolarTerm } from '../model/SolarTerm';
import { SolarTermData } from '../engine/SolarTermData';
import { Palette, Utils } from '../common/Constants';
import { TermCard } from '../components/TermCard';
import { SeasonHeader } from '../components/SeasonHeader';

class TimelineSource implements IDataSource {
  private items: TimelineItem[] = [];
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.items.length;
  }

  getData(index: number): TimelineItem {
    return this.items[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index: number = this.listeners.indexOf(listener);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  setItems(items: TimelineItem[]): void {
    this.items = items;
    for (let i: number = 0; i < this.listeners.length; i++) {
      this.listeners[i].onDataReloaded();
    }
  }
}

@Component
export struct TimelineView {
  onOpenTerm: (termId: string) => void = (termId: string) => {
  };
  @State year: number = 2026;
  @State season: string = '全部';
  @State total: number = 0;
  @State ready: boolean = false;
  private years: number[] = [];
  private source: TimelineSource = new TimelineSource();

  aboutToAppear(): void {
    this.years = SolarTermData.getYears();
    if (this.years.length > 0) {
      const nowYear: number = new Date().getFullYear();
      this.year = this.years.indexOf(nowYear) >= 0 ? nowYear : this.years[0];
    }
    this.rebuild();
    this.ready = true;
  }

  private buildItems(): TimelineItem[] {
    const items: TimelineItem[] = [];
    const seasons: string[] = this.season === '全部' ? Utils.SEASONS : [this.season];
    for (let i: number = 0; i < seasons.length; i++) {
      const season: string = seasons[i];
      const terms: SolarTerm[] = SolarTermData.getBySeason(this.year, season);
      if (terms.length === 0) {
        continue;
      }
      const header: TimelineItem = {
        key: this.year + '-' + season + '-header',
        kind: 'header',
        season: season,
        year: this.year,
        term: emptySolarTerm()
      };
      items.push(header);
      for (let j: number = 0; j < terms.length; j++) {
        const term: SolarTerm = terms[j];
        const item: TimelineItem = {
          key: term.id,
          kind: 'term',
          season: season,
          year: this.year,
          term: term
        };
        items.push(item);
      }
    }
    return items;
  }

  private rebuild(): void {
    this.source.setItems(this.buildItems());
    this.total = this.source.totalCount();
  }

  private selectYear(year: number): void {
    if (this.year === year) {
      return;
    }
    this.year = year;
    this.rebuild();
  }

  private selectSeason(season: string): void {
    if (this.season === season) {
      return;
    }
    this.season = season;
    this.rebuild();
  }

  @Builder
  YearChip(year: number) {
    Text('' + year)
      .fontSize(12)
      .fontWeight(this.year === year ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.year === year ? Color.White : Palette.INK_SOFT)
      .backgroundColor(this.year === year ? Palette.INK : Color.Transparent)
      .borderRadius(14)
      .padding({ left: 14, right: 14, top: 6, bottom: 6 })
      .margin({ right: 8 })
      .onClick(() => {
        this.selectYear(year);
      })
  }

  @Builder
  SeasonChip(season: string) {
    Text(season)
      .fontSize(12)
      .fontWeight(this.season === season ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.season === season ? Color.White :
        (season === '全部' ? Palette.INK_SOFT : Utils.seasonColor(season)))
      .backgroundColor(this.season === season ?
        (season === '全部' ? Palette.INK : Utils.seasonColor(season)) : Palette.CARD_BG)
      .border({ width: 1, color: season === '全部' ? '#E9DFCE' : Utils.seasonSoft(season) })
      .borderRadius(14)
      .padding({ left: 13, right: 13, top: 5, bottom: 5 })
      .margin({ right: 7 })
      .onClick(() => {
        this.selectSeason(season);
      })
  }

  build() {
    Column({ space: 4 }) {
      Row() {
        Column({ space: 4 }) {
          Text('二十四节气轴')
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .fontColor(Palette.INK)
          Text('2026 — 2027 · 精确交节时刻')
            .fontSize(10)
            .letterSpacing(1)
            .fontColor(Palette.INK_FAINT)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('轴')
          .fontSize(18)
          .fontColor(Palette.SEAL_RED)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .border({ width: 2, color: Palette.SEAL_RED })
          .borderRadius(6)
      }
      .width('100%')
      .padding({ top: 4, bottom: 6 })

      Row() {
        ForEach(this.years, (year: number) => {
          this.YearChip(year)
        }, (year: number) => 'year-' + year)
      }
      .width('100%')
      .padding({ top: 4, bottom: 4 })

      Row() {
        this.SeasonChip('全部')
        ForEach(Utils.SEASONS, (season: string) => {
          this.SeasonChip(season)
        }, (season: string) => 'season-' + season)
      }
      .width('100%')
      .padding({ top: 2, bottom: 6 })

      if (this.ready && this.total === 0) {
        Column({ space: 8 }) {
          Text('暂无节气数据')
            .fontSize(14)
            .fontColor(Palette.INK_SOFT)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          LazyForEach(this.source, (item: TimelineItem) => {
            ListItem() {
              if (item.kind === 'header') {
                SeasonHeader({
                  season: item.season,
                  year: item.year,
                  count: SolarTermData.getBySeason(item.year, item.season).length
                })
              } else {
                TermCard({
                  term: item.term,
                  showYear: false,
                  onTap: (term: SolarTerm) => {
                    this.onOpenTerm(term.id);
                  }
                })
              }
            }
          }, (item: TimelineItem) => item.key)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .padding({ bottom: 90 })
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 18, right: 18, top: 14 })
    .backgroundColor(Palette.PAGE_BG)
  }
}
