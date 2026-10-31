import { DatabaseHelper, makeFeedRecord } from '../database/DatabaseHelper';
import {
  FeedRecord,
  FeedType,
  PeriodRecords,
  buildDailyRecords,
  DailyRecord
} from '../model/Models';
import { Theme } from '../utils/Theme';
import { TimeUtils } from '../utils/TimeUtils';
import { NursingTimerCard } from '../components/NursingTimerCard';
import { RecordCard } from '../components/RecordCard';

/**
 * 喂养页：母乳左右侧计时 + 奶瓶毫升 + 辅食 + 今日喂养列表
 */
@Component
export struct FeedPage {
  @StorageLink('dataVersion') @Watch('onReload') dataVersion: number = 0;
  @State todayFeeds: FeedRecord[] = [];
  @State dailyRecords: DailyRecord[] = [];
  @State bottleAmount: number = 120;
  @State solidName: string = '';
  @State solidNote: string = '';
  @State loading: boolean = false;

  aboutToAppear(): void {
    this.loadToday();
  }

  onReload(): void {
    this.loadToday();
  }

  private async loadToday(): Promise<void> {
    this.loading = true;
    try {
      const start = TimeUtils.todayStart();
      const records: PeriodRecords =
        await DatabaseHelper.getInstance().queryPeriodRecords(start, start + TimeUtils.DAY);
      this.todayFeeds = records.feeds;
      this.dailyRecords = buildDailyRecords(records);
    } catch (e) {
      console.error('FeedPage loadToday failed: ' + e);
    }
    this.loading = false;
  }

  private totalBottleMl(): number {
    let total = 0;
    for (let i = 0; i < this.todayFeeds.length; i++) {
      if (this.todayFeeds[i].type === FeedType.Bottle || this.todayFeeds[i].type === FeedType.Solid) {
        total += this.todayFeeds[i].amount;
      }
    }
    return total;
  }

  private nursingCountToday(): number {
    let count = 0;
    for (let i = 0; i < this.todayFeeds.length; i++) {
      const t = this.todayFeeds[i].type;
      if (t === FeedType.NursingLeft || t === FeedType.NursingRight) {
        count++;
      }
    }
    return count;
  }

  private lastFeedHint(): string {
    if (this.todayFeeds.length === 0) {
      return '今天还没有喂养记录';
    }
    const latest = this.todayFeeds[0];
    return '上次喂养：' + TimeUtils.agoText(latest.startTime, Date.now());
  }

  private async saveNursing(side: string, durationMs: number): Promise<void> {
    const type = side === 'left' ? FeedType.NursingLeft : FeedType.NursingRight;
    const record = makeFeedRecord(type, 0, durationMs, '');
    await DatabaseHelper.getInstance().insertFeed(record);
    this.dataVersion++;
  }

  private async saveBottle(): Promise<void> {
    const record = makeFeedRecord(FeedType.Bottle, this.bottleAmount, 0, '');
    await DatabaseHelper.getInstance().insertFeed(record);
    this.dataVersion++;
  }

  private async saveSolid(): Promise<void> {
    if (this.solidName.trim().length === 0) {
      return;
    }
    const note = this.solidNote.trim().length > 0
      ? this.solidName.trim() + ' · ' + this.solidNote.trim()
      : this.solidName.trim();
    const record = makeFeedRecord(FeedType.Solid, 0, 0, note);
    await DatabaseHelper.getInstance().insertFeed(record);
    this.solidName = '';
    this.solidNote = '';
    this.dataVersion++;
  }

  private async deleteRecord(kind: string, recordId: number): Promise<void> {
    if (kind !== 'feed') {
      return;
    }
    await DatabaseHelper.getInstance().deleteFeed(recordId);
    this.dataVersion++;
  }

  @Builder
  sectionTitle(title: string, extra: string) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.TEXT)
      Blank()
      Text(extra)
        .fontSize(12)
        .fontColor(Theme.TEXT_SUB)
    }
    .width('100%')
    .margin({ top: 20, bottom: 10 })
  }

  @Builder
  quickMlChip(ml: number) {
    Text(ml + 'ml')
      .fontSize(13)
      .fontColor(this.bottleAmount === ml ? Color.White : Theme.TEXT_SUB)
      .backgroundColor(this.bottleAmount === ml ? Theme.PRIMARY : Theme.GRAY_BG)
      .borderRadius(16)
      .padding({ left: 14, right: 14, top: 6, bottom: 6 })
      .margin({ right: 8 })
      .onClick(() => {
        this.bottleAmount = ml;
      })
  }

  build() {
    Scroll() {
      Column() {
        this.sectionTitle('母乳喂养', this.nursingCountToday() + ' 次')
        Row() {
          Column() {
            NursingTimerCard({
              side: 'left',
              title: '左侧',
              accentColor: Theme.PINK,
              onFinish: (side: string, durationMs: number) => {
                this.saveNursing(side, durationMs);
              },
              onDiscard: (side: string) => {
                console.info('nursing discarded: ' + side);
              }
            })
          }
          .layoutWeight(1)

          Column() {
            NursingTimerCard({
              side: 'right',
              title: '右侧',
              accentColor: Theme.PURPLE,
              onFinish: (side: string, durationMs: number) => {
                this.saveNursing(side, durationMs);
              },
              onDiscard: (side: string) => {
                console.info('nursing discarded: ' + side);
              }
            })
          }
          .layoutWeight(1)
          .margin({ left: 10 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        Text(this.lastFeedHint())
          .fontSize(12)
          .fontColor(Theme.TEXT_LIGHT)
          .margin({ top: 8 })

        this.sectionTitle('奶瓶喂养', '今日 ' + this.totalBottleMl() + 'ml')
        Column() {
          Row() {
            Text(this.bottleAmount + ' ml')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.PRIMARY)
            Blank()
            Text('滑动选择奶量')
              .fontSize(12)
              .fontColor(Theme.TEXT_LIGHT)
          }
          .width('100%')

          Slider({
            value: this.bottleAmount,
            min: 10,
            max: 320,
            step: 10,
            style: SliderStyle.OutSet
          })
            .selectedColor(Theme.PRIMARY)
            .trackColor(Theme.GRAY_BG)
            .blockColor(Theme.PRIMARY)
            .width('100%')
            .margin({ top: 12, bottom: 8 })
            .onChange((value: number) => {
              this.bottleAmount = Math.round(value);
            })

          Row() {
            this.quickMlChip(60)
            this.quickMlChip(90)
            this.quickMlChip(120)
            this.quickMlChip(150)
            this.quickMlChip(180)
          }
          .width('100%')

          Button('记录这次奶瓶')
            .width('100%')
            .height(42)
            .fontSize(15)
            .backgroundColor(Theme.PRIMARY)
            .margin({ top: 14 })
            .onClick(() => {
              this.saveBottle();
            })
        }
        .width('100%')
        .padding(14)
        .backgroundColor(Theme.CARD)
        .borderRadius(16)

        this.sectionTitle('辅食', '')
        Column() {
          TextInput({ placeholder: '吃了什么，如：米粉、果泥' })
            .height(42)
            .fontSize(14)
            .backgroundColor(Theme.GRAY_BG)
            .onChange((value: string) => {
              this.solidName = value;
            })
          TextInput({ placeholder: '份量 / 备注（可选）' })
            .height(42)
            .fontSize(14)
            .backgroundColor(Theme.GRAY_BG)
            .margin({ top: 8 })
            .onChange((value: string) => {
              this.solidNote = value;
            })
          Button('记录辅食')
            .width('100%')
            .height(42)
            .fontSize(15)
            .backgroundColor(Theme.BLUE)
            .margin({ top: 12 })
            .enabled(this.solidName.trim().length > 0)
            .opacity(this.solidName.trim().length > 0 ? 1 : 0.5)
            .onClick(() => {
              this.saveSolid();
            })
        }
        .width('100%')
        .padding(14)
        .backgroundColor(Theme.CARD)
        .borderRadius(16)

        this.sectionTitle('今日记录', this.todayFeeds.length + ' 条')
        if (this.dailyRecords.length === 0) {
          Text('还没有记录，从上面开始打卡吧')
            .fontSize(13)
            .fontColor(Theme.TEXT_LIGHT)
            .margin({ top: 24, bottom: 24 })
        } else {
          List() {
            ForEach(this.dailyRecords, (item: DailyRecord) => {
              ListItem() {
                RecordCard({
                  icon: item.icon,
                  title: item.title,
                  subtitle: item.subtitle,
                  timeMs: item.timeMs,
                  deletable: true,
                  kind: item.kind,
                  recordId: item.recordId,
                  onDelete: (kind: string, recordId: number) => {
                    this.deleteRecord(kind, recordId);
                  }
                })
              }
              .margin({ bottom: 8 })
            }, (item: DailyRecord) => item.kind + item.recordId.toString())
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
  }
}
