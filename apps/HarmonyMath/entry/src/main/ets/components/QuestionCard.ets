import { Theme } from '../model/Theme';

@Component
export struct QuestionCard {
  @Prop index: number = 0;
  @Prop total: number = 0;
  @Prop stem: string = '';
  @Prop userAnswer: string = '';
  @Prop feedback: string = '';
  @Prop correctAnswer: number = 0;
  @Prop progress: number = 1;
  @Prop limitSec: number = 0;
  @Prop elapsed: number = 0;

  build() {
    Column({ space: 16 }) {
      Row() {
        Text(`第 ${this.index} / ${this.total} 题`)
          .fontSize(14)
          .fontColor(Theme.TEXT_SECONDARY)
        Blank()
        if (this.limitSec > 0) {
          Text(`剩余 ${this.timeLeftText()} 秒`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.progress > 0.3 ? Theme.PRIMARY : Theme.DANGER)
        } else {
          Text(`已用时 ${this.elapsed} 秒`)
            .fontSize(14)
            .fontColor(Theme.TEXT_SECONDARY)
        }
      }
      .width('100%')

      if (this.limitSec > 0) {
        Progress({ value: this.progressPercent(), total: 100, type: ProgressType.Linear })
          .color(this.progress > 0.3 ? Theme.PRIMARY : Theme.DANGER)
          .width('100%')
      }

      Column({ space: 24 }) {
        Text(this.stem)
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.TEXT_DARK)
          .maxLines(1)

        Text(this.userAnswer === '' ? '输入答案' : this.userAnswer)
          .fontSize(32)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.answerColor())
          .padding({ left: 32, right: 32, top: 8, bottom: 8 })
          .borderRadius(12)
          .backgroundColor(this.answerBackground())
          .scale(this.feedback !== '' ? { x: 1.12, y: 1.12 } : { x: 1, y: 1 })
          .animation({ duration: 180, curve: Curve.EaseOut })

        if (this.feedback === 'wrong') {
          Text(`正确答案：${this.correctAnswer}`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.DANGER)
            .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
        }

        if (this.feedback === 'correct') {
          Text('回答正确！')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.SUCCESS)
            .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
        }
      }
      .width('100%')
      .padding({ top: 32, bottom: 32, left: 24, right: 24 })
      .borderRadius(20)
      .backgroundColor(Color.White)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .borderRadius(20)
    .backgroundColor(Color.White)
  }

  private progressPercent(): number {
    const percent: number = Math.round(this.progress * 100);
    if (percent < 0) {
      return 0;
    }
    if (percent > 100) {
      return 100;
    }
    return percent;
  }

  private timeLeftText(): string {
    const left: number = Math.ceil(this.limitSec * this.progress);
    return left < 0 ? '0' : `${left}`;
  }

  private answerColor(): ResourceColor {
    if (this.feedback === 'correct') {
      return Theme.SUCCESS;
    }
    if (this.feedback === 'wrong') {
      return Theme.DANGER;
    }
    return Theme.TEXT_DARK;
  }

  private answerBackground(): ResourceColor {
    if (this.feedback === 'correct') {
      return Theme.SUCCESS_LIGHT;
    }
    if (this.feedback === 'wrong') {
      return Theme.DANGER_LIGHT;
    }
    return Theme.KEY_BG;
  }
}
