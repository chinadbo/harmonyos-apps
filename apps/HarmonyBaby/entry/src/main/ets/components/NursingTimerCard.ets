import { Theme } from '../utils/Theme';
import { TimeUtils } from '../utils/TimeUtils';

/**
 * 母乳喂养计时卡：按侧别计时，结束时回调 onFinish，误触可取消（不记录）
 */
@Component
export struct NursingTimerCard {
  @Prop side: string = 'left';
  @Prop title: string = '左侧';
  @Prop accentColor: string = Theme.PINK;
  @State isRunning: boolean = false;
  @State elapsedMs: number = 0;
  private startMs: number = 0;
  private timerId: number = -1;
  onFinish: (side: string, durationMs: number) => void = (side: string, durationMs: number) => {
  };
  onDiscard: (side: string) => void = (side: string) => {
  };

  aboutToDisappear(): void {
    this.clearTimer();
  }

  private clearTimer(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private start(): void {
    this.startMs = Date.now();
    this.elapsedMs = 0;
    this.isRunning = true;
    this.timerId = setInterval(() => {
      this.elapsedMs = Date.now() - this.startMs;
    }, 250);
  }

  private finish(): void {
    const duration = this.elapsedMs;
    this.clearTimer();
    this.isRunning = false;
    this.elapsedMs = 0;
    if (duration >= 5000) {
      this.onFinish(this.side, duration);
    } else {
      // 计时不足 5 秒视为误触，不记录
      this.onDiscard(this.side);
    }
  }

  private cancel(): void {
    this.clearTimer();
    this.isRunning = false;
    this.elapsedMs = 0;
    this.onDiscard(this.side);
  }

  build() {
    Column() {
      Row() {
        Text(this.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.TEXT)
        Blank()
        Text(this.isRunning ? '计时中' : '未开始')
          .fontSize(11)
          .fontColor(this.isRunning ? Color.White : Theme.TEXT_LIGHT)
          .backgroundColor(this.isRunning ? this.accentColor : Theme.GRAY_BG)
          .borderRadius(8)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
      }
      .width('100%')

      Text(TimeUtils.formatClock(this.elapsedMs))
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isRunning ? this.accentColor : Theme.TEXT)
        .margin({ top: 10, bottom: 4 })

      Text(this.isRunning ? '正在哺乳，加油！' : '点击开始记录这侧哺乳')
        .fontSize(11)
        .fontColor(Theme.TEXT_LIGHT)

      if (!this.isRunning) {
        Button('开始')
          .width('100%')
          .height(38)
          .fontSize(14)
          .backgroundColor(this.accentColor)
          .margin({ top: 12 })
          .onClick(() => {
            this.start();
          })
      } else {
        Row() {
          Button('结束')
            .height(38)
            .fontSize(14)
            .layoutWeight(1)
            .backgroundColor(this.accentColor)
            .onClick(() => {
              this.finish();
            })
          Button('取消')
            .height(38)
            .fontSize(14)
            .layoutWeight(1)
            .backgroundColor(Theme.GRAY_BG)
            .fontColor(Theme.TEXT_SUB)
            .margin({ left: 8 })
            .onClick(() => {
              this.cancel();
            })
        }
        .width('100%')
        .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.CARD)
    .borderRadius(16)
    .border({
      width: this.isRunning ? 1.5 : 0,
      color: this.accentColor
    })
  }
}
