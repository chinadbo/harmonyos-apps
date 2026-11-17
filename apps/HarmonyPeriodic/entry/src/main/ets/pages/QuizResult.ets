import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';
import { dbHelper, QuizRecord } from '../utils/db';

const DOMAIN: number = 0x0000;
const TAG: string = 'QuizResult';

interface ResultParams {
  correct: number;
  total: number;
}

function pad2(value: number): string {
  return value < 10 ? '0' + value.toString() : value.toString();
}

function formatRecordDate(iso: string): string {
  const date: Date = new Date(iso);
  if (Number.isNaN(date.getTime())) {
    return iso;
  }
  return date.getFullYear().toString() + '-' + pad2(date.getMonth() + 1) + '-' +
    pad2(date.getDate()) + ' ' + pad2(date.getHours()) + ':' + pad2(date.getMinutes());
}

function rateOf(correct: number, total: number): number {
  return total > 0 ? Math.round(correct * 100 / total) : 0;
}

function rateColor(rate: number): string {
  if (rate >= 80) {
    return '#1F7A3D';
  }
  if (rate >= 60) {
    return '#0A59F7';
  }
  return '#C7361F';
}

@Entry
@Component
struct QuizResult {
  @State correct: number = 0;
  @State total: number = 0;
  @State records: QuizRecord[] = [];
  @State loading: boolean = true;
  @State errorMessage: string = '';
  @State hasCurrent: boolean = false;

  aboutToAppear(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    this.loading = true;
    try {
      const params: ResultParams = router.getParams() as ResultParams;
      if (params !== undefined && params !== null &&
        typeof params.correct === 'number' && typeof params.total === 'number' &&
        params.total > 0) {
        this.correct = params.correct;
        this.total = params.total;
        this.hasCurrent = true;
      }
      const context = getContext(this) as common.UIAbilityContext;
      await dbHelper.init(context);
      this.records = await dbHelper.getQuizRecords();
      if (!this.hasCurrent && this.records.length > 0) {
        this.correct = this.records[0].correct;
        this.total = this.records[0].total;
      }
      this.errorMessage = '';
    } catch (err) {
      this.errorMessage = '测验记录加载失败，请重试';
      hilog.error(DOMAIN, TAG, 'load quiz result failed: %{public}s', JSON.stringify(err));
    } finally {
      this.loading = false;
    }
  }

  private accuracy(): number {
    return rateOf(this.correct, this.total);
  }

  private encourageText(): string {
    if (this.total === 0) {
      return '完成一次测验即可查看成绩';
    }
    const rate: number = this.accuracy();
    if (rate >= 90) {
      return '太棒了，你是元素达人！';
    }
    if (rate >= 70) {
      return '表现不错，再接再厉';
    }
    if (rate >= 50) {
      return '基础还行，继续加油';
    }
    return '多复习几遍元素表吧';
  }

  private restartQuiz(): void {
    router.replaceUrl({ url: 'pages/QuizPage' }).catch((err: Error) => {
      hilog.error(DOMAIN, TAG, 'restart quiz failed: %{public}s', err.message);
    });
  }

  build() {
    Column() {
      this.Header()
      if (this.loading) {
        Column({ space: 8 }) {
          LoadingProgress()
            .width(36)
            .height(36)
            .color('#0A59F7')
          Text('正在加载成绩')
            .fontSize(13)
            .fontColor('#99000000')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            if (this.errorMessage.length > 0) {
              Text(this.errorMessage)
                .fontSize(13)
                .fontColor('#C7361F')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(10)
                .backgroundColor('#FDECE9')
                .borderRadius(10)
            }
            this.ScoreCard()
            this.HistorySection()
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 12, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)

        this.BottomAction()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  @Builder
  Header() {
    Row() {
      Text('返回')
        .fontSize(14)
        .fontColor('#0A59F7')
        .padding({ left: 4, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          router.back();
        })
      Column({ space: 2 }) {
        Text('测验结果')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E6000000')
        Text('成绩已保存到本机')
          .fontSize(11)
          .fontColor('#99000000')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
    }
    .width('100%')
    .padding({ left: 10, right: 14, top: 10, bottom: 6 })
  }

  @Builder
  ScoreCard() {
    Column({ space: 6 }) {
      Text(this.total > 0 ? this.accuracy().toString() + '%' : '--')
        .fontSize(60)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.total > 0 ? rateColor(this.accuracy()) : '#66000000')
      Text('正确率')
        .fontSize(13)
        .fontColor('#99000000')
      Text('答对 ' + this.correct.toString() + ' / ' + this.total.toString() + ' 题')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#E6000000')
        .margin({ top: 4 })
      Text(this.encourageText())
        .fontSize(13)
        .fontColor('#66000000')
        .margin({ top: 2 })
    }
    .width('100%')
    .padding({ top: 22, bottom: 22, left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }

  @Builder
  HistorySection() {
    Column({ space: 10 }) {
      Row() {
        Text('历史成绩')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#E6000000')
        Blank()
        Text('共 ' + this.records.length.toString() + ' 次')
          .fontSize(11)
          .fontColor('#66000000')
      }
      .width('100%')

      if (this.records.length === 0) {
        Column({ space: 6 }) {
          Text('暂无历史成绩')
            .fontSize(14)
            .fontColor('#66000000')
          Text('完成一次测验后，成绩会记录在这里')
            .fontSize(12)
            .fontColor('#99000000')
        }
        .width('100%')
        .padding({ top: 22, bottom: 22 })
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(this.records, (record: QuizRecord) => {
          this.RecordRow(record)
        }, (record: QuizRecord) => record.id.toString())
      }
    }
    .width('100%')
  }

  @Builder
  RecordRow(record: QuizRecord) {
    Row({ space: 12 }) {
      Column({ space: 4 }) {
        Text(formatRecordDate(record.date))
          .fontSize(14)
          .fontColor('#E6000000')
        Text('答对 ' + record.correct.toString() + ' / ' + record.total.toString() + ' 题')
          .fontSize(12)
          .fontColor('#99000000')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(rateOf(record.correct, record.total).toString() + '%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(rateColor(rateOf(record.correct, record.total)))
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  BottomAction() {
    Column() {
      Divider()
        .width('100%')
        .color('#14000000')
      Row() {
        Button('重新测验', { type: ButtonType.Normal })
          .width('100%')
          .height(46)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor('#0A59F7')
          .borderRadius(12)
          .onClick(() => {
            this.restartQuiz();
          })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 10, bottom: 12 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }
}
