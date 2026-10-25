/**
 * 错题本：错题列表、批量选择移除、一键重刷
 */
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { Question } from '../data/Question'
import { QuestionBank } from '../data/QuestionBank'
import { DbHelper, WrongEntry } from '../store/DbHelper'

@Component
struct WrongRow {
  @Prop qid: number = 0
  @Prop selected: boolean = false
  @Prop wrongCount: number = 0
  @Prop stem: string = ''
  @Prop chapter: string = ''
  @Prop isJudge: boolean = false
  onToggle: () => void = () => {}
  onOpen: () => void = () => {}

  build() {
    Row() {
      Checkbox()
        .select(this.selected)
        .selectedColor('#DC2626')
        .width(22)
        .height(22)
        .onClick(() => this.onToggle())
      Column() {
        Text(this.stem)
          .fontSize(14)
          .fontColor('#1F2937')
          .lineHeight(21)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row() {
          Text(this.isJudge ? '判断' : '单选')
            .fontSize(11)
            .fontColor('#6B7280')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor('#F3F4F6')
            .borderRadius(6)
          Text(this.chapter)
            .fontSize(11)
            .fontColor('#9CA3AF')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .constraintSize({ maxWidth: '50%' })
            .margin({ left: 6 })
          Blank()
          Text(`错 ${this.wrongCount} 次`)
            .fontSize(11)
            .fontColor('#DC2626')
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .layoutWeight(1)
      .margin({ left: 10 })
      .onClick(() => this.onOpen())
    }
    .width('100%')
    .padding(14)
    .borderRadius(14)
    .backgroundColor('#FFFFFF')
    .margin({ bottom: 10 })
    .alignItems(VerticalAlign.Top)
  }
}

@Entry
@Component
struct WrongBookPage {
  @StorageLink('currentSubject') currentSubject: number = 1
  @State entries: WrongEntry[] = []
  @State selected: Set<number> = new Set()
  @State loading: boolean = true

  aboutToAppear(): void {
    this.reload()
  }

  onPageShow(): void {
    this.reload()
  }

  async reload(): Promise<void> {
    this.loading = true
    this.entries = await DbHelper.wrongList(this.currentSubject)
    this.selected = new Set()
    this.loading = false
  }

  private questionOf(qid: number): Question | undefined {
    return QuestionBank.getQuestion(qid)
  }

  private toggle(qid: number): void {
    if (this.selected.has(qid)) {
      this.selected.delete(qid)
    } else {
      this.selected.add(qid)
    }
    this.selected = new Set(this.selected)
  }

  private async removeSelected(): Promise<void> {
    if (this.selected.size === 0) {
      promptAction.showToast({ message: '请先勾选要移除的错题' })
      return
    }
    await DbHelper.removeWrongBatch(Array.from(this.selected))
    promptAction.showToast({ message: `已移除 ${this.selected.size} 道错题` })
    this.reload()
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('‹')
          .fontSize(26)
          .fontColor('#1F2937')
          .padding({ left: 4, right: 4 })
          .onClick(() => router.back())
        Text(`错题本 · ${this.currentSubject === 1 ? '科目一' : '科目四'}`)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .margin({ left: 6 })
        Blank()
        Text(`${this.entries.length} 题`)
          .fontSize(13)
          .fontColor('#DC2626')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .padding({ left: 14, right: 16, top: 10, bottom: 8 })

      if (this.loading) {
        Column() {
          LoadingProgress().width(36).height(36).color('#DC2626')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.entries.length === 0) {
        Column() {
          Text('🎉')
            .fontSize(44)
          Text('错题本空空如也，继续保持！')
            .fontSize(14)
            .fontColor('#6B7280')
            .margin({ top: 12 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.entries, (e: WrongEntry) => {
              WrongRow({
                qid: e.qid,
                selected: this.selected.has(e.qid),
                wrongCount: e.wrongCount,
                stem: this.questionOf(e.qid)?.stem ?? '题目已从题库移除',
                chapter: this.questionOf(e.qid)?.chapter ?? '',
                isJudge: this.questionOf(e.qid)?.type === 'judge',
                onToggle: () => this.toggle(e.qid),
                onOpen: () => {
                  router.pushUrl({
                    url: 'pages/PracticePage',
                    params: { subject: e.subject, qids: [e.qid] } as Record<string, Object>
                  })
                }
              })
            }, (e: WrongEntry) => `wrong-${e.qid}-${e.wrongCount}`)

            Row() {
              Text('全选')
                .fontSize(13)
                .fontColor('#6B7280')
                .padding(8)
                .onClick(() => {
                  if (this.selected.size === this.entries.length) {
                    this.selected = new Set()
                  } else {
                    const s = new Set<number>()
                    this.entries.forEach(e => s.add(e.qid))
                    this.selected = s
                  }
                })
              Blank()
              Text(`已选 ${this.selected.size} 题`)
                .fontSize(12)
                .fontColor('#9CA3AF')
            }
            .width('100%')
            .padding({ top: 4, bottom: 8 })
          }
          .padding({ left: 14, right: 14 })
          .constraintSize({ minWidth: '100%' })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      // 底部操作
      if (!this.loading && this.entries.length > 0) {
        Row() {
          Button('重刷全部错题')
            .fontSize(15)
            .height(42)
            .layoutWeight(1)
            .fontColor('#FFFFFF')
            .backgroundColor('#DC2626')
            .borderRadius(21)
            .onClick(() => {
              const qids: number[] = []
              this.entries.forEach(e => qids.push(e.qid))
              router.pushUrl({
                url: 'pages/PracticePage',
                params: { subject: this.currentSubject, qids: qids } as Record<string, Object>
              })
            })
          Button('移除勾选')
            .fontSize(15)
            .height(42)
            .layoutWeight(1)
            .fontColor('#1F2937')
            .backgroundColor('#F3F4F6')
            .borderRadius(21)
            .margin({ left: 12 })
            .onClick(() => this.removeSelected())
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 6, bottom: 14 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
