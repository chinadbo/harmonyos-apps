import { SleepRecord, formatDuration, formatTime } from '../model/SleepRecord';

@Component
export struct SleepStatusCard {
  @Prop @Watch('onSleepStateChange') isSleeping: boolean = false;
  @Prop sleepStartTime: number = 0;
  @Prop lastRecord: SleepRecord = {
    id: 0, sleepTime: 0, wakeTime: 0, duration: 0, quality: 0, note: '', createdAt: 0
  };
  @State elapsed: number = 0;
  private timer: number = -1;

  aboutToAppear(): void {
    if (this.isSleeping) {
      this.startTimer();
    }
  }

  onSleepStateChange(): void {
    if (this.isSleeping) {
      this.startTimer();
    } else {
      if (this.timer !== -1) {
        clearInterval(this.timer);
        this.timer = -1;
        this.elapsed = 0;
      }
    }
  }

  aboutToDisappear(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  startTimer(): void {
    this.elapsed = Math.floor((Date.now() - this.sleepStartTime) / 60000);
    this.timer = setInterval(() => {
      this.elapsed = Math.floor((Date.now() - this.sleepStartTime) / 60000);
    }, 60000);
  }

  build() {
    Column() {
      if (this.isSleeping) {
        Image($r('app.media.app_icon'))
          .width(48)
          .height(48)
          .margin({ bottom: 8 })
        Text('正在睡眠中')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5B8DEF')
        Text(formatDuration(this.elapsed))
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A2E')
          .margin({ top: 4 })
        Text(`入睡时间：${formatTime(this.sleepStartTime)}`)
          .fontSize(14)
          .fontColor('#888888')
          .margin({ top: 8 })
      } else if (this.lastRecord.id > 0) {
        Text('上次睡眠')
          .fontSize(14)
          .fontColor('#888888')
        Text(formatDuration(this.lastRecord.duration))
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A2E')
          .margin({ top: 4 })
        Text(`${formatTime(this.lastRecord.sleepTime)} - ${formatTime(this.lastRecord.wakeTime)}`)
          .fontSize(14)
          .fontColor('#888888')
          .margin({ top: 4 })
      } else {
        Image($r('app.media.app_icon'))
          .width(48)
          .height(48)
          .opacity(0.4)
          .margin({ bottom: 8 })
        Text('今日暂无睡眠记录')
          .fontSize(16)
          .fontColor('#BBBBBB')
      }
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .height(160)
  }
}
