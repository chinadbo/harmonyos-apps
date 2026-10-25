/**
 * 模拟考试：100 题限时 45 分钟、答题卡面板、交卷评分
 */
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { Question, optionLabel } from '../data/Question'
import { QuestionBank } from '../data/QuestionBank'
import { ExamEngine, ExamReport } from '../data/ExamEngine'

@Component
struct SheetCell {
  @Prop num: number = 0
  @Prop answered: boolean = false
  @Prop current: boolean = false
  onTap: (num: number) => void = () => {}

  build() {
    Text(`${this.num}`)
      .fontSize(13)
      .fontColor(this.current ? '#FFFFFF' : (this.answered ? '#1C64F2' : '#9CA3AF'))
      .width(36)
      .height(36)
      .textAlign(TextAlign.Center)
      .borderRadius(18)
      .backgroundColor(this.current ? '#1C64F2' : (this.answered ? '#E8F0FE' : '#F3F4F6'))
      .border({ width: this.current ? 0 : 1, color: '#E5E7EB' })
      .onClick(() => this.onTap(this.num))
  }
}

@Entry
@Component
struct ExamPage {
  @StorageLink('currentSubject') currentSubject: number = 1
  @State engine: ExamEngine = new ExamEngine()
  @State paper: Question[] = []
  @State index: number = 0
  @State chosen: number[] = []
  @State remainText: string = '45:00'
  @State showSheet: boolean = false
  @State running: boolean = false
  @State confirming: boolean = false
  private timer: number = -1

  aboutToAppear(): void {
    const bankSize = QuestionBank.getBySubject(this.currentSubject).length
    if (bankSize === 0) {
      promptAction.showToast({ message: '题库尚未加载完成，请稍后重试' })
      setTimeout(() => router.back(), 800)
      return
    }
    this.engine.start(this.currentSubject)
    this.paper = this.engine.paper
    this.chosen = this.paper.map(() => -1)
    this.remainText = this.engine.formatRemain()
    this.running = true
    this.timer = setInterval(() => {
      if (this.engine.submitted) {
        return
      }
      this.engine.remainSeconds--
      this.remainText = this.engine.formatRemain()
      if (this.engine.remainSeconds <= 0) {
        promptAction.showToast({ message: '时间到，自动交卷' })
        this.finishExam()
      }
    }, 1000)
  }

  aboutToDisappear(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer)
      this.timer = -1
    }
  }

  private onOption(optIdx: number): void {
    if (this.engine.submitted) {
      return
    }
    this.chosen[this.index] = optIdx
    this.chosen = this.chosen.slice()
    this.engine.answer(this.index, optIdx)
  }

  private async finishExam(): Promise<void> {
    if (this.timer >= 0) {
      clearInterval(this.timer)
      this.timer = -1
    }
    const report: ExamReport = await this.engine.submit()
    AppStorage.setOrCreate('lastExamReport', report)
    router.replaceUrl({ url: 'pages/ExamResultPage' })
  }

  build() {
    Column() {
      // 顶部：退出 / 计时 / 已答
      Row() {
        Text('退出')
          .fontSize(14)
          .fontColor('#DC2626')
          .padding(6)
          .onClick(() => {
            this.confirming = true
          })
        Blank()
        Text(this.remainText)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.engine.remainSeconds <= 300 ? '#DC2626' : '#1F2937')
        Blank()
        Text(`已答 ${this.engine.answeredCount()}/${this.paper.length}`)
          .fontSize(13)
          .fontColor('#6B7280')
      }
      .width('100%')
      .padding({ left: 12, right: 14, top: 10, bottom: 8 })

      // 题目区
      if (this.paper.length > 0) {
        Scroll() {
          Column() {
            Text(this.paper[this.index].stem)
              .fontSize(17)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F2937')
              .lineHeight(26)
              .width('100%')
              .alignSelf(ItemAlign.Start)

            ForEach(this.paper[this.index].options, (opt: string, idx: number) => {
              Row() {
                Text(optionLabel(idx))
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.chosen[this.index] === idx ? '#FFFFFF' : '#1F2937')
                  .width(26)
                  .height(26)
                  .textAlign(TextAlign.Center)
                  .borderRadius(13)
                  .backgroundColor(this.chosen[this.index] === idx ? '#1C64F2' : '#F3F4F6')
                Text(opt)
                  .fontSize(15)
                  .fontColor(this.chosen[this.index] === idx ? '#1C64F2' : '#1F2937')
                  .layoutWeight(1)
                  .margin({ left: 10 })
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .padding({ left: 14, right: 14, top: 12, bottom: 12 })
              .borderRadius(12)
              .backgroundColor(this.chosen[this.index] === idx ? '#E8F0FE' : '#FFFFFF')
              .margin({ bottom: 10 })
              .onClick(() => this.onOption(idx))
            }, (opt: string, idx: number) => `${this.paper[this.index].id}-${idx}`)
          }
          .padding({ left: 16, right: 16, top: 6, bottom: 16 })
          .constraintSize({ minWidth: '100%' })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      // 底部：上一题/答题卡/下一题
      Row() {
        Button('上一题')
          .fontSize(14)
          .height(38)
          .fontColor('#1F2937')
          .backgroundColor('#F3F4F6')
          .borderRadius(19)
          .padding({ left: 16, right: 16 })
          .enabled(this.index > 0)
          .onClick(() => {
            if (this.index > 0) {
              this.index--
            }
          })
        Blank()
        Button('答题卡')
          .fontSize(14)
          .height(38)
          .fontColor('#1C64F2')
          .backgroundColor('#E8F0FE')
          .borderRadius(19)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.showSheet = true
          })
        Blank()
        if (this.index < this.paper.length - 1) {
          Button('下一题')
            .fontSize(14)
            .height(38)
            .fontColor('#FFFFFF')
            .backgroundColor('#1C64F2')
            .borderRadius(19)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              if (this.index < this.paper.length - 1) {
                this.index++
              }
            })
        } else {
          Button('交卷')
            .fontSize(14)
            .height(38)
            .fontColor('#FFFFFF')
            .backgroundColor('#16A34A')
            .borderRadius(19)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              this.confirming = true
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 14 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .bindSheet($$this.showSheet, this.sheetBuilder(), { height: 500 })
    .bindContentCover(this.confirming, this.confirmBuilder())
  }

  @Builder
  sheetBuilder() {
    Column() {
      Text(`答题卡 · 已答 ${this.engine.answeredCount()} 题`)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2937')
        .margin({ top: 16, bottom: 12 })
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
        ForEach(this.paper, (q: Question, i: number) => {
          SheetCell({
            num: i + 1,
            answered: this.chosen[i] >= 0,
            current: i === this.index,
            onTap: (n: number) => {
              this.index = n - 1
              this.showSheet = false
            }
          })
        }, (q: Question) => `sheet-${q.id}`)
      }
      .padding({ left: 12, right: 12 })
      Button('交卷')
        .fontSize(15)
        .height(42)
        .width('60%')
        .fontColor('#FFFFFF')
        .backgroundColor('#16A34A')
        .borderRadius(21)
        .margin({ top: 18 })
        .onClick(() => {
          this.showSheet = false
          this.confirming = true
        })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  confirmBuilder() {
    Column() {
      Text('确认交卷？')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2937')
      Text(`还有 ${this.paper.length - this.engine.answeredCount()} 题未作答，交卷后立即评分`)
        .fontSize(14)
        .fontColor('#6B7280')
        .margin({ top: 10 })
      Row() {
        Button('继续答题')
          .fontSize(14)
          .height(40)
          .layoutWeight(1)
          .fontColor('#1F2937')
          .backgroundColor('#F3F4F6')
          .borderRadius(20)
          .onClick(() => {
            this.confirming = false
          })
        Button('退出考试')
          .fontSize(14)
          .height(40)
          .layoutWeight(1)
          .fontColor('#FFFFFF')
          .backgroundColor('#6B7280')
          .borderRadius(20)
          .margin({ left: 10 })
          .onClick(() => {
            this.confirming = false
            router.back()
          })
        Button('确认交卷')
          .fontSize(14)
          .height(40)
          .layoutWeight(1)
          .fontColor('#FFFFFF')
          .backgroundColor('#1C64F2')
          .borderRadius(20)
          .margin({ left: 10 })
          .onClick(() => {
            this.confirming = false
            this.finishExam()
          })
      }
      .width('100%')
      .margin({ top: 24 })
    }
    .width('88%')
    .padding(24)
    .borderRadius(20)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
    .margin({ top: 160 })
  }
}
