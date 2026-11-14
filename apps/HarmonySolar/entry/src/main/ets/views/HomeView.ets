import { SolarTerm, emptySolarTerm } from '../model/SolarTerm';
import { LunarDate } from '../model/LunarDate';
import { SolarTermData } from '../engine/SolarTermData';
import { LunarCalendar } from '../engine/LunarCalendar';
import { Palette, Utils } from '../common/Constants';
import { SolarRing } from '../components/SolarRing';

@Component
export struct HomeView {
  onOpenTerm: (termId: string) => void = (termId: string) => {
  };
  onOpenTimeline: () => void = () => {
  };

  private now: Date = new Date();
  private current: SolarTerm = emptySolarTerm();
  private next: SolarTerm = emptySolarTerm();
  private lunar: LunarDate | null = null;
  private progress: number = 0;
  private daysToNext: number = 0;
  private houIndex: number = 0;
  private upcoming: SolarTerm[] = [];

  aboutToAppear(): void {
    this.refresh();
  }

  private refresh(): void {
    if (!SolarTermData.isReady()) {
      return;
    }
    this.now = new Date();
    const current: SolarTerm | undefined = SolarTermData.getForDate(this.now);
    if (current !== undefined) {
      this.current = current;
    }
    const next: SolarTerm | undefined = SolarTermData.getNext(this.now);
    if (next !== undefined) {
      this.next = next;
    }
    this.progress = SolarTermData.getProgress(this.now, this.current, next);
    this.daysToNext = SolarTermData.getDaysToNext(this.now, next);
    this.houIndex = SolarTermData.getHouIndex(this.now, this.current);
    this.lunar = LunarCalendar.solarToLunar(this.now.getFullYear(), this.now.getMonth() + 1, this.now.getDate());
    this.upcoming = SolarTermData.getUpcoming(this.now, 4);
  }

  private lunarText(): string {
    if (this.lunar === null) {
      return '';
    }
    return '农历 ' + this.lunar.text + ' · ' + this.lunar.zodiac + '年';
  }

  private nextMoment(): string {
    return this.next.id === '' ? '暂无数据' : Utils.shortMoment(this.next);
  }

  private currentMoment(): string {
    return this.current.id === '' ? '暂无数据' : Utils.shortMoment(this.current);
  }

  private nextDistance(): string {
    if (this.next.id === '') {
      return '';
    }
    return '距离「' + this.next.name + '」' + Utils.daysText(this.daysToNext);
  }

  @Builder
  StatItem(label: string, value: string) {
    Column({ space: 3 }) {
      Text(label)
        .fontSize(9)
        .letterSpacing(1)
        .fontColor(Palette.INK_FAINT)
      Text(value)
        .fontSize(12)
        .fontColor(Palette.INK)
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  Chip(text: string, fg: string, bg: string) {
    Text(text)
      .fontSize(11)
      .fontColor(fg)
      .backgroundColor(bg)
      .borderRadius(8)
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .margin({ right: 6, bottom: 6 })
  }

  @Builder
  UpcomingCard(term: SolarTerm) {
    Column({ space: 4 }) {
      Text(term.season)
        .fontSize(9)
        .fontColor(Utils.seasonColor(term.season))
        .letterSpacing(1)
      Text(term.name)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(Palette.INK)
      Text(Utils.shortMoment(term))
        .fontSize(9)
        .fontColor(Palette.INK_FAINT)
    }
    .width(96)
    .padding({ left: 10, right: 10, top: 12, bottom: 12 })
    .backgroundColor(Palette.CARD_BG)
    .borderRadius(14)
    .border({ width: 1, color: '#F2EBDD' })
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      this.onOpenTerm(term.id);
    })
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Column({ space: 6 }) {
            Text('HARMONYSOLAR')
              .fontSize(10)
              .letterSpacing(3)
              .fontColor(Palette.GOLD)
            Text(Utils.fullDate(this.now))
              .fontSize(25)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.INK)
            Text(Utils.weekday(this.now) + ' · ' + this.lunarText())
              .fontSize(11)
              .fontColor(Palette.INK_SOFT)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Column({ space: 1 }) {
            Text(this.current.season)
              .fontSize(22)
              .fontColor(Palette.SEAL_RED)
            Text('SEASON')
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

        Column({ space: 7 }) {
          Row() {
            Text('当前节气')
              .fontSize(10)
              .letterSpacing(2)
              .fontColor(Palette.INK_SOFT)
            Blank()
            Text(Utils.progressPercent(this.progress) + ' 行程')
              .fontSize(10)
              .fontColor(Utils.seasonColor(this.current.season))
          }
          .width('100%')

          SolarRing({
            progress: this.progress,
            ringColor: Utils.seasonColor(this.current.season),
            trackColor: Utils.seasonSoft(this.current.season),
            ringSize: 252,
            centerTitle: this.current.name,
            centerSub: this.current.en.toUpperCase(),
            centerFootTop: this.nextDistance(),
            centerFoot: this.current.id === '' ? '' : ('交节 ' + this.currentMoment())
          })

          Row() {
            this.StatItem('本轮交节', this.currentMoment())
            Divider()
              .vertical(true)
              .height(26)
              .color('#EBE1CF')
            this.StatItem('下一节气', this.next.id === '' ? '暂无数据' : this.next.name + ' ' + this.nextMoment())
          }
          .width('100%')
          .padding({ top: 4 })
        }
        .width('100%')
        .padding(18)
        .borderRadius(26)
        .linearGradient({
          angle: 135,
          colors: [[Utils.seasonSoft(this.current.season), 0.0], ['#FFFFFF', 0.62],
            [Utils.seasonSoft(this.current.season), 1.0]]
        })
        .border({ width: 1, color: '#F1E8D8' })
        .alignItems(HorizontalAlign.Center)

        Column({ space: 10 }) {
          Row() {
            Column({ space: 2 }) {
              Text(this.current.name + '三候')
                .fontSize(17)
                .fontWeight(FontWeight.Medium)
                .fontColor(Palette.INK)
              Text('五日为一候 · 三候为一气')
                .fontSize(10)
                .fontColor(Palette.INK_FAINT)
            }
            .alignItems(HorizontalAlign.Start)
            Blank()
            Text('第 ' + Utils.HOU_LABELS[this.houIndex] + ' · ' + (this.houIndex + 1) + '/3')
              .fontSize(10)
              .fontColor(Utils.seasonColor(this.current.season))
              .backgroundColor(Utils.seasonSoft(this.current.season))
              .borderRadius(8)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          }
          .width('100%')

          ForEach(this.current.yuxiang, (item: string, index: number) => {
            Row({ space: 10 }) {
              Text(Utils.HOU_LABELS[index])
                .fontSize(10)
                .fontColor(index === this.houIndex ? Color.White : Utils.seasonColor(this.current.season))
                .width(40)
                .height(24)
                .textAlign(TextAlign.Center)
                .borderRadius(12)
                .backgroundColor(index === this.houIndex ? Utils.seasonColor(this.current.season) :
                  Utils.seasonSoft(this.current.season))
              Text(item)
                .fontSize(15)
                .fontWeight(index === this.houIndex ? FontWeight.Medium : FontWeight.Normal)
                .fontColor(index === this.houIndex ? Palette.INK : Palette.INK_SOFT)
                .layoutWeight(1)
              if (index === this.houIndex) {
                Text('当令')
                  .fontSize(9)
                  .fontColor(Palette.GOLD)
                  .border({ width: 1, color: Palette.GOLD })
                  .borderRadius(4)
                  .padding({ left: 4, right: 4, top: 1, bottom: 1 })
              }
            }
            .width('100%')
            .padding({ left: 10, right: 10, top: 8, bottom: 8 })
            .borderRadius(12)
            .backgroundColor(index === this.houIndex ? '#FBF5E9' : Color.Transparent)
          }, (item: string) => this.current.id + '-hou-' + item)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Palette.CARD_BG)
        .borderRadius(20)
        .border({ width: 1, color: '#F2EBDD' })

        Row({ space: 12 }) {
          Column({ space: 8 }) {
            Row({ space: 6 }) {
              Text('宜')
                .fontSize(13)
                .fontColor(Color.White)
                .width(24)
                .height(24)
                .textAlign(TextAlign.Center)
                .borderRadius(12)
                .backgroundColor(Utils.seasonColor('春'))
              Text('SUIT')
                .fontSize(8)
                .letterSpacing(1)
                .fontColor(Utils.seasonColor('春'))
            }
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.current.suitable, (item: string) => {
                this.Chip(item, '#3F7550', '#EAF2E9')
              }, (item: string) => this.current.id + '-suit-' + item)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .padding(12)
          .backgroundColor('#F5F8F1')
          .borderRadius(18)

          Column({ space: 8 }) {
            Row({ space: 6 }) {
              Text('忌')
                .fontSize(13)
                .fontColor(Color.White)
                .width(24)
                .height(24)
                .textAlign(TextAlign.Center)
                .borderRadius(12)
                .backgroundColor(Palette.SEAL_RED)
              Text('AVOID')
                .fontSize(8)
                .letterSpacing(1)
                .fontColor(Palette.SEAL_RED)
            }
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.current.taboos, (item: string) => {
                this.Chip(item, '#8B3A31', '#FAECE8')
              }, (item: string) => this.current.id + '-avoid-' + item)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .padding(12)
          .backgroundColor('#FBF1EE')
          .borderRadius(18)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        Column({ space: 10 }) {
          Row({ space: 8 }) {
            Text('接下来的节气')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.INK)
            Blank()
            Text('查看全部 ›')
              .fontSize(11)
              .fontColor(Palette.GOLD)
              .onClick(() => {
                this.onOpenTimeline();
              })
          }
          .width('100%')

          Scroll() {
            Row({ space: 10 }) {
              ForEach(this.upcoming, (term: SolarTerm) => {
                this.UpcomingCard(term)
              }, (term: SolarTerm) => 'up-' + term.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }
        .width('100%')

        Column({ space: 8 }) {
          Row() {
            Text('节气诗词')
              .fontSize(10)
              .letterSpacing(2)
              .fontColor(Palette.GOLD)
            Blank()
            Text(this.current.poem.author)
              .fontSize(11)
              .fontColor(Palette.INK_FAINT)
          }
          .width('100%')
          Text('《' + this.current.poem.title + '》')
            .fontSize(13)
            .fontColor(Palette.INK)
          Text(this.current.poem.content)
            .fontSize(13)
            .lineHeight(24)
            .fontColor(Palette.INK_SOFT)
            .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(16)
        .backgroundColor('#F7F1E6')
        .borderRadius(18)

        Text('顺应天时 · 记录节气')
          .fontSize(10)
          .letterSpacing(2)
          .fontColor(Palette.INK_FAINT)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 4, bottom: 90 })
      }
      .padding({ left: 20, right: 20, top: 14 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(Palette.PAGE_BG)
  }
}
