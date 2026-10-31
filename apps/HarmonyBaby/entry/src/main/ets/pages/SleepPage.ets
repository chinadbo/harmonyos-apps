import { DatabaseHelper } from '../database/DatabaseHelper';
import {
  SleepRecord,
  SleepQuality,
  sleepQualityText
} from '../model/Models';
import { Theme } from '../utils/Theme';
import { TimeUtils } from '../utils/TimeUtils';

/**
 * 睡眠页：开始/结束打卡自动计算时长 + 睡眠质量 + 今日睡眠列表
 */
@Component
export struct SleepPage {
  @StorageLink('dataVersion') @Watch('onReload') dataVersion: number = 0;
  @State ongoing: SleepRecord | null = null;
  @State ongoingStartMs: number = 0;
  @State todaySleeps: SleepRecord[] = [];
  @State elapsedMs: number = 0;
  @State quality: string = SleepQuality.Good;
  private tickTimerId: number = -1;

  aboutToAppear(): void {
    this.loadToday();
  }

  aboutToDisappear(): void {
    this.stopTick();
  }

  onReload(): void {
    this.loadToday();
  }

  private stopTick(): void {
    if (this.tickTimerId >= 0) {
      clearInterval(this.tickTimerId);
      this.tickTimerId = -1;
    }
  }

  private startTick(): void {
    this.stopTick();
    this.tickTimerId = setInterval(() => {
      if (this.ongoing !== null) {
        this.elapsedMs = Date.now() - this.ongoing.startTime;
      }
    }, 1000);
  }

  private async loadToday(): Promise<void> {
    try {
      const start = TimeUtils.todayStart();
      const sleeps = await DatabaseHelper.getInstance().querySleepsBetween(start, start + TimeUtils.DAY);
      const ongoing = await DatabaseHelper.getInstance().getOngoingSleep();
      this.todaySleeps = sleeps;
      if (ongoing !== null && TimeUtils.sameDay(ongoing.startTime, Date.now())) {
        this.ongoing = ongoing;
        this.ongoingStartMs = ongoing.startTime;
        this.elapsedMs = Date.now() - ongoing.startTime;
        this.startTick();
      } else {
        this.ongoing = null;
        this.elapsedMs = 0;
        this.stopTick();
      }
    } catch (e) {
      console.error('SleepPage loadToday failed: ' + e);
    }
  }

  private totalSleepMs(): number {
    let total = this.elapsedMs;
    for (let i = 0; i < this.todaySleeps.length; i++) {
      const s = this.todaySleeps[i];
      if (s.endTime > 0) {
        total += s.endTime - s.startTime;
      }
    }
    return total;
  }

  private nightFeedHint(): string {
    // 提示：睡眠期间是否错过喂奶（供参考）
    if (this.todaySleeps.length === 0) {
      return ' ';
    }
    return '建议关注白天小睡与夜觉的分布';
  }

  private async startSleep(): Promise<void> {
    const now = Date.now();
    const id = await DatabaseHelper.getInstance().startSleep(now);
    const r = new SleepRecord();
    r.id = id;
    r.startTime = now;
    r.endTime = 0;
    r.quality = this.quality;
    this.ongoing = r;
    this.ongoingStartMs = now;
    this.elapsedMs = 0;
    this.startTick();
    this.dataVersion++;
  }

  private async finishSleep(): Promise<void> {
    const current = this.ongoing;
    if (current === null) {
      return;
    }
    const now = Date.now();
    await DatabaseHelper.getInstance().finishSleep(current.id, now, this.quality);
    this.stopTick();
    this.ongoing = null;
    this.elapsedMs = 0;
    this.dataVersion++;
  }

  private async deleteRecord(id: number): Promise<void> {
    await DatabaseHelper.getInstance().deleteSleep(id);
    this.dataVersion++;
  }

  @Builder
  qualityChip(q: string) {
    Text(sleepQualityText(q))
      .fontSize(13)
      .fontColor(this.quality === q ? Color.White : Theme.TEXT_SUB)
      .backgroundColor(this.quality === q ? Theme.PURPLE : Theme.GRAY_BG)
      .borderRadius(16)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .margin({ right: 10 })
      .onClick(() => {
        this.quality = q;
      })
  }

  @Builder
  sleepItem(record: SleepRecord) {
    Row() {
      Text('😴')
        .fontSize(22)
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .borderRadius(12)
        .backgroundColor(Theme.GRAY_BG)
      Column() {
        Text(TimeUtils.formatTime(record.startTime) + ' - ' +
          (record.endTime > 0 ? TimeUtils.formatTime(record.endTime) : '…'))
          .fontSize(14)
          .fontColor(Theme.TEXT)
        Row() {
          Text(TimeUtils.formatDuration(record.duration()))
            .fontSize(12)
            .fontColor(Theme.TEXT_SUB)
          Text(sleepQualityText(record.quality))
            .fontSize(12)
            .fontColor(Theme.TEXT_LIGHT)
            .margin({ left: 8 })
        }
        .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      Text('✕')
        .fontSize(14)
        .fontColor(Theme.TEXT_LIGHT)
        .width(32)
        .height(32)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.deleteRecord(record.id);
        })
    }
    .width('100%')
    .padding(10)
    .backgroundColor(Theme.CARD)
    .borderRadius(14)
  }

  build() {
    Scroll() {
      Column() {
        // 当前睡眠状态卡
        Column() {
          if (this.ongoing === null) {
            Text('💤')
              .fontSize(40)
              .margin({ top: 6 })
            Text('宝宝醒着')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.TEXT)
              .margin({ top: 8 })
            Text('点击下方按钮，在宝宝入睡时开始计时')
              .fontSize(12)
              .fontColor(Theme.TEXT_SUB)
              .margin({ top: 4, bottom: 12 })
            Button('入睡打卡')
              .width('100%')
              .height(44)
              .fontSize(16)
              .backgroundColor(Theme.PURPLE)
              .margin({ top: 4 })
              .onClick(() => {
                this.startSleep();
              })
          } else {
            Text('😴')
              .fontSize(40)
              .margin({ top: 6 })
            Text('睡眠中')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.PURPLE)
              .margin({ top: 8 })
            Text(TimeUtils.formatClock(this.elapsedMs))
              .fontSize(34)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.PURPLE)
              .margin({ top: 4 })
            Text(TimeUtils.formatTime(this.ongoingStartMs) + ' 入睡 · 自动计算时长')
              .fontSize(12)
              .fontColor(Theme.TEXT_SUB)
              .margin({ top: 4 })
            Row() {
              Text('睡得怎么样：')
                .fontSize(13)
                .fontColor(Theme.TEXT_SUB)
              this.qualityChip(SleepQuality.Good)
              this.qualityChip(SleepQuality.Fair)
              this.qualityChip(SleepQuality.Poor)
            }
            .margin({ top: 12 })
            Button('醒来打卡')
              .width('100%')
              .height(44)
              .fontSize(16)
              .backgroundColor(Theme.PURPLE)
              .margin({ top: 12 })
              .onClick(() => {
                this.finishSleep();
              })
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Theme.CARD)
        .borderRadius(16)

        // 今日睡眠统计
        Row() {
          Column() {
            Text(TimeUtils.formatDurationShort(this.totalSleepMs()))
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.PURPLE)
            Text('今日总睡眠')
              .fontSize(12)
              .fontColor(Theme.TEXT_SUB)
              .margin({ top: 2 })
          }
          .layoutWeight(1)

          Column() {
            Text(this.todaySleeps.length.toString())
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.TEXT)
            Text('睡眠次数')
              .fontSize(12)
              .fontColor(Theme.TEXT_SUB)
              .margin({ top: 2 })
          }
          .layoutWeight(1)

          Column() {
            Text(this.longestSleepText())
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.GREEN)
            Text('最长一觉')
              .fontSize(12)
              .fontColor(Theme.TEXT_SUB)
              .margin({ top: 2 })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(14)
        .backgroundColor(Theme.CARD)
        .borderRadius(16)
        .margin({ top: 12 })

        Text(this.nightFeedHint())
          .fontSize(12)
          .fontColor(Theme.TEXT_LIGHT)
          .margin({ top: 8 })

        Row() {
          Text('今日睡眠')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT)
          Blank()
          Text(this.todaySleeps.length + ' 条')
            .fontSize(12)
            .fontColor(Theme.TEXT_SUB)
        }
        .width('100%')
        .margin({ top: 20, bottom: 10 })

        if (this.todaySleeps.length === 0) {
          Text('今天还没有睡眠记录')
            .fontSize(13)
            .fontColor(Theme.TEXT_LIGHT)
            .margin({ top: 24, bottom: 24 })
        } else {
          List() {
            ForEach(this.todaySleeps, (record: SleepRecord) => {
              ListItem() {
                this.sleepItem(record)
              }
              .margin({ bottom: 8 })
            }, (record: SleepRecord) => record.id.toString() + record.endTime.toString())
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

  private longestSleepText(): string {
    let longest = 0;
    for (let i = 0; i < this.todaySleeps.length; i++) {
      const d = this.todaySleeps[i].duration();
      if (d > longest) {
        longest = d;
      }
    }
    if (this.elapsedMs > longest) {
      longest = this.elapsedMs;
    }
    return TimeUtils.formatDurationShort(longest);
  }
}
