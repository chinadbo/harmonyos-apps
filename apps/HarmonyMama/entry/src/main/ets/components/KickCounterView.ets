import promptAction from '@ohos.promptAction';
import hilog from '@ohos.hilog';
import { BusinessError } from '@ohos.base';
import { DbHelper } from '../database/DbHelper';
import { KickSession } from '../model/KickSession';
import { formatTimer, todayStr } from '../utils/PregnancyCalc';

const DOMAIN: number = 0x0000;
const TAG: string = 'KickCounterView';
const PINK: string = '#F062A3';
const PINK_DARK: string = '#D6336C';
const TITLE_COLOR: string = '#3A2C33';
const BODY_COLOR: string = '#5A4A52';
const MUTED_COLOR: string = '#A98D9B';
const CARD_BG: string = '#FFFFFF';

@Component
export struct KickCounterView {
  @Prop @Watch('onTick') refreshTick: number = 0;

  @State running: boolean = false;
  @State currentCount: number = 0;
  @State elapsedSeconds: number = 0;
  @State scale: number = 1;
  @State sessions: KickSession[] = [];
  @State totalCount: number = 0;

  private timerId: number = -1;
  private startTime: string = '';
  private sessionDate: string = todayStr();

  aboutToAppear(): void {
    this.loadToday();
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  onTick(): void {
    this.loadToday();
  }

  private pad2(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  private nowTimeLabel(): string {
    const now: Date = new Date();
    return `${this.pad2(now.getHours())}:${this.pad2(now.getMinutes())}`;
  }

  private async loadToday(): Promise<void> {
    this.sessionDate = todayStr();
    try {
      const list: KickSession[] = await DbHelper.getInstance().queryKickSessionsByDate(this.sessionDate);
      let total: number = 0;
      for (let i = 0; i < list.length; i++) {
        total += list[i].count;
      }
      this.sessions = list;
      this.totalCount = total;
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'loadToday failed: %{public}d %{public}s', error.code, error.message);
      this.sessions = [];
      this.totalCount = 0;
    }
  }

  private startTimer(): void {
    this.stopTimer();
    this.timerId = setInterval(() => {
      this.elapsedSeconds = this.elapsedSeconds + 1;
    }, 1000);
  }

  private stopTimer(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private pulse(): void {
    animateTo({ duration: 90, curve: Curve.EaseOut }, () => {
      this.scale = 0.9;
    });
    setTimeout(() => {
      animateTo({ duration: 130, curve: Curve.EaseOut }, () => {
        this.scale = 1;
      });
    }, 90);
  }

  private startSession(): void {
    if (this.running) {
      return;
    }
    this.sessionDate = todayStr();
    this.running = true;
    this.currentCount = 0;
    this.elapsedSeconds = 0;
    this.startTime = this.nowTimeLabel();
    this.scale = 1;
    this.startTimer();
  }

  private recordKick(): void {
    if (!this.running) {
      return;
    }
    this.currentCount = this.currentCount + 1;
    this.pulse();
  }

  private async endSession(): Promise<void> {
    if (!this.running) {
      return;
    }
    this.stopTimer();
    const count: number = this.currentCount;
    const seconds: number = this.elapsedSeconds;
    this.running = false;
    this.scale = 1;
    if (count === 0) {
      this.currentCount = 0;
      this.elapsedSeconds = 0;
      promptAction.showToast({ message: '本次没有记录到胎动' });
      return;
    }
    const session: KickSession = new KickSession();
    session.date = this.sessionDate;
    session.startTime = this.startTime;
    session.count = count;
    session.durationMin = Math.max(1, Math.ceil(seconds / 60));
    try {
      await DbHelper.getInstance().insertKickSession(session);
      promptAction.showToast({ message: `已保存 ${count} 次胎动` });
      this.currentCount = 0;
      this.elapsedSeconds = 0;
      await this.loadToday();
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'endSession failed: %{public}d %{public}s', error.code, error.message);
      promptAction.showToast({ message: '保存失败，请重试' });
    }
  }

  @Builder
  header() {
    Row() {
      Column() {
        Text('胎动计数')
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .fontColor(TITLE_COLOR)
        Text('每天固定时段记录，观察宝宝的活跃规律')
          .fontSize(12)
          .fontColor(MUTED_COLOR)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('👣')
        .fontSize(28)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 14 })
  }

  @Builder
  counterCard() {
    Column() {
      Row() {
        Text(this.running ? '计时中' : '准备就绪')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.running ? PINK_DARK : MUTED_COLOR)
          .backgroundColor(this.running ? '#FFF0F6' : '#F7F1F4')
          .borderRadius(11)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })

        Text(formatTimer(this.elapsedSeconds))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.running ? PINK_DARK : '#BCA7B2')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Row() {
        Column() {
          Text(this.running ? `${this.currentCount}` : '👣')
            .fontSize(this.running ? 62 : 42)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text(this.running ? '次胎动' : '点击「开始会话」')
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.92)')
            .margin({ top: 4 })
        }
        .width(196)
        .height(196)
        .borderRadius(98)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .linearGradient({
          angle: 135,
          colors: [['#FFB6D5', 0.0], ['#FF8DBE', 0.55], ['#F26BA8', 1.0]]
        })
        .scale({ x: this.scale, y: this.scale })
        .shadow({ radius: 20, color: 'rgba(242,107,168,0.35)', offsetX: 0, offsetY: 8 })
        .onClick(() => {
          this.recordKick();
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 14, bottom: 16 })

      if (this.running) {
        Row() {
          Text('结束并保存')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .borderRadius(24)
        .backgroundColor(PINK)
        .onClick(() => {
          this.endSession();
        })
        Text('轻触圆盘记录一次胎动')
          .fontSize(12)
          .fontColor(MUTED_COLOR)
          .margin({ top: 8 })
      } else {
        Row() {
          Text('开始会话')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .borderRadius(24)
        .backgroundColor(PINK)
        .onClick(() => {
          this.startSession();
        })
        Text('静坐放松，选择宝宝活跃的时段开始')
          .fontSize(12)
          .fontColor(MUTED_COLOR)
          .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(CARD_BG)
    .borderRadius(22)
    .alignItems(HorizontalAlign.Center)
    .shadow({ radius: 12, color: 'rgba(214,51,108,0.08)', offsetX: 0, offsetY: 4 })
  }

  @Builder
  summaryCard() {
    Column() {
      Text('今日汇总')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(TITLE_COLOR)
        .width('100%')
      Row() {
        Column() {
          Text(`${this.totalCount}`)
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(PINK_DARK)
          Text('累计胎动（次）')
            .fontSize(11)
            .fontColor(MUTED_COLOR)
            .margin({ top: 2 })
        }
        .layoutWeight(1)

        Divider()
          .vertical(true)
          .height(36)
          .color('#F2DCE7')

        Column() {
          Text(`${this.sessions.length}`)
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(PINK_DARK)
          Text('有效会话')
            .fontSize(11)
            .fontColor(MUTED_COLOR)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 12 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFF4F9')
    .borderRadius(18)
    .margin({ top: 14 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  sessionRow(session: KickSession) {
    Row() {
      Column() {
        Text('👶')
          .fontSize(16)
      }
      .width(34)
      .height(34)
      .borderRadius(17)
      .backgroundColor('#FFF0F6')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ right: 12 })

      Column() {
        Text(`${session.startTime} 开始`)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(TITLE_COLOR)
        Text(`${session.durationMin} 分钟 · ${session.count} 次`)
          .fontSize(12)
          .fontColor(MUTED_COLOR)
          .margin({ top: 3 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(`${session.count} 次`)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(PINK_DARK)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .border({ width: { bottom: 0.5 }, color: '#F6E7EF' })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  sessionsCard() {
    Column() {
      Row() {
        Text('今日会话')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(TITLE_COLOR)
          .layoutWeight(1)
        Text(`${this.sessions.length} 次`)
          .fontSize(12)
          .fontColor('#C58AA6')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      if (this.sessions.length === 0) {
        Column() {
          Text('今天还没有记录')
            .fontSize(13)
            .fontColor('#B59AA8')
          Text('点击「开始会话」记录第一次胎动吧')
            .fontSize(11)
            .fontColor('#C9B2BE')
            .margin({ top: 4 })
        }
        .width('100%')
        .padding({ top: 22, bottom: 14 })
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(this.sessions, (session: KickSession) => {
          this.sessionRow(session)
        }, (session: KickSession) => `${session.id}`)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(CARD_BG)
    .borderRadius(22)
    .margin({ top: 16 })
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 12, color: 'rgba(214,51,108,0.08)', offsetX: 0, offsetY: 4 })
  }

  @Builder
  tipCard() {
    Column() {
      Row() {
        Text('💡')
          .fontSize(15)
        Text('胎动小提示')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(PINK_DARK)
          .margin({ left: 6 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text('孕 28 周起建议每天固定时段数胎动。若 1 小时内胎动少于 3 次，或明显比平时减少，请及时就医咨询。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(BODY_COLOR)
        .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFF0F6')
    .borderRadius(20)
    .margin({ top: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Scroll() {
      Column() {
        this.header()
        this.counterCard()
        this.summaryCard()
        this.sessionsCard()
        this.tipCard()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 18, bottom: 28 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF6FA')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
