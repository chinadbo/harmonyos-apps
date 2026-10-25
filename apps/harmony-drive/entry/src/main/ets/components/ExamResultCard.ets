/**
 * 考试结果卡：分数环、合格判定、薄弱章节
 */
import { ExamReport } from '../data/ExamEngine'
import { PASS_SCORE } from '../data/Question'

function emptyReport(): ExamReport {
  return {
    score: 0, total: 0, correct: 0, wrong: 0, blank: 0,
    passed: false, weakChapters: [], wrongQids: []
  }
}

@Component
export struct ExamResultCard {
  @Prop report: ExamReport = emptyReport()

  private scoreColor(): string {
    return this.report.score >= PASS_SCORE ? '#16A34A' : '#DC2626'
  }

  @Builder
  StatCell(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2937')
      Text(label)
        .fontSize(12)
        .fontColor('#6B7280')
        .margin({ top: 2 })
    }
  }

  build() {
    Column() {
      Stack() {
        Progress({
          value: this.report.score,
          total: 100,
          type: ProgressType.Ring
        })
          .style({ strokeWidth: 10 })
          .width(150)
          .height(150)
          .color(this.scoreColor())
        Column() {
          Text(`${this.report.score}`)
            .fontSize(44)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.scoreColor())
          Text('分')
            .fontSize(14)
            .fontColor('#6B7280')
        }
      }
      .margin({ top: 8 })

      Text(this.report.passed ? '恭喜，考试合格！' : '很遗憾，未达 90 分合格线')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.scoreColor())
        .margin({ top: 16 })

      Row() {
        this.StatCell(`${this.report.correct}`, '答对')
        Divider().vertical().height(28).color('#E5E7EB')
        this.StatCell(`${this.report.wrong}`, '答错')
        Divider().vertical().height(28).color('#E5E7EB')
        this.StatCell(`${this.report.blank}`, '未答')
      }
      .width('90%')
      .margin({ top: 20 })
      .justifyContent(FlexAlign.SpaceBetween)

      if (this.report.weakChapters.length > 0) {
        Column() {
          Text('薄弱章节')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2937')
            .alignSelf(ItemAlign.Start)
          ForEach(this.report.weakChapters, (name: string) => {
            Text(`· ${name}`)
              .fontSize(13)
              .fontColor('#DC2626')
              .margin({ top: 6 })
              .alignSelf(ItemAlign.Start)
          }, (name: string) => name)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding(14)
        .borderRadius(12)
        .backgroundColor('#FEF2F2')
        .margin({ top: 24 })
      }
    }
    .width('100%')
    .padding(24)
    .borderRadius(20)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Center)
  }
}
