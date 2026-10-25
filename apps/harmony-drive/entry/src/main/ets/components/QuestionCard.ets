/**
 * 题目卡片：题号/章节/题干/选项列表/判分/解析展开
 */
import { Question, optionLabel } from '../data/Question'
import { OptionItem } from './OptionItem'

function emptyQuestion(): Question {
  return {
    id: 0, subject: 1, chapter: '', tag: 'general', type: 'single',
    stem: '加载中…', options: [], answer: 0, explanation: ''
  }
}

@Component
export struct QuestionCard {
  @Prop question: Question = emptyQuestion()
  @Prop index: number = 0 // 展示序号，从 1 开始
  @Prop total: number = 0
  @Prop chosen: number = -1 // 已选索引，-1 未答
  @Prop showResult: boolean = false
  @Prop showAnswer: boolean = false // 练习模式下点击"看答案"
  @Prop showExplanation: boolean = false
  onSelect: (index: number) => void = () => {}

  private effective(): boolean {
    return this.showResult || this.showAnswer
  }

  private isCorrect(): boolean {
    return this.chosen === this.question.answer
  }

  build() {
    Column() {
      Row() {
        Text(`第 ${this.index} / ${this.total} 题`)
          .fontSize(13)
          .fontColor('#6B7280')
        Blank()
        Text(this.question.type === 'judge' ? '判断题' : '单选题')
          .fontSize(12)
          .fontColor('#1C64F2')
          .backgroundColor('#E8F0FE')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(8)
        Text(this.question.chapter)
          .fontSize(12)
          .fontColor('#6B7280')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ left: 6 })
      }
      .width('100%')

      Text(this.question.stem)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2937')
        .lineHeight(26)
        .margin({ top: 12, bottom: 16 })
        .alignSelf(ItemAlign.Start)

      ForEach(this.question.options, (opt: string, idx: number) => {
        OptionItem({
          text: opt,
          index: idx,
          selected: this.chosen === idx,
          showResult: this.effective(),
          isAnswer: idx === this.question.answer,
          onSelect: (i: number) => this.onSelect(i)
        })
      }, (opt: string, idx: number) => `${this.question.id}-${idx}`)

      if (this.effective()) {
        Row() {
          Text(this.isCorrect() ? '回答正确' : `正确答案：${optionLabel(this.question.answer)}`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.isCorrect() ? '#16A34A' : '#DC2626')
          Blank()
          Text('解析')
            .fontSize(13)
            .fontColor('#1C64F2')
            .onClick(() => {
              this.showExplanation = !this.showExplanation
            })
        }
        .width('100%')
        .margin({ top: 4 })

        if (this.showExplanation) {
          Text(this.question.explanation === '' ? '本题暂无解析' : this.question.explanation)
            .fontSize(14)
            .fontColor('#4B5563')
            .lineHeight(22)
            .width('100%')
            .padding(12)
            .borderRadius(10)
            .backgroundColor('#F5F7FA')
            .margin({ top: 8 })
            .alignSelf(ItemAlign.Start)
        }
      }
    }
    .width('100%')
    .padding(16)
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
  }
}
