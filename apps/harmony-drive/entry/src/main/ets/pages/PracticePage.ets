/**
 * 顺序练习：章节筛选 / 上一题下一题 / 即时判分 / 答题记录入库
 */
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { Question } from '../data/Question'
import { QuestionBank } from '../data/QuestionBank'
import { DbHelper } from '../store/DbHelper'
import { PrefsHelper } from '../store/PrefsHelper'
import { QuestionCard } from '../components/QuestionCard'

interface PracticeParams {
  subject?: number
  tag?: string
  qids?: number[]
  title?: string
}

@Component
struct ChapterChip {
  @Prop label: string = ''
  @Prop active: boolean = false
  onTap: () => void = () => {}

  build() {
    Text(this.label)
      .fontSize(13)
      .fontColor(this.active ? '#FFFFFF' : '#4B5563')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(14)
      .backgroundColor(this.active ? '#1C64F2' : '#F3F4F6')
      .onClick(() => this.onTap())
  }
}

@Entry
@Component
struct PracticePage {
  @StorageLink('currentSubject') currentSubject: number = 1
  @State questions: Question[] = []
  @State index: number = 0
  @State chosen: number[] = []
  @State answered: boolean[] = []
  @State showAnswer: boolean[] = []
  @State chapterFilter: string = ''
  @State chapters: string[] = []
  @State ready: boolean = false
  private savedOnce: boolean = false

  aboutToAppear(): void {
    const params = router.getParams() as PracticeParams
    let subject = this.currentSubject
    if (params !== undefined && params.subject !== undefined) {
      subject = params.subject
      this.currentSubject = subject
    }
    let list: Question[] = []
    if (params !== undefined && params.qids !== undefined) {
      // 错题本重刷等场景：外部传入题目列表
      const all = QuestionBank.all()
      list = all.filter(q => (params.qids as number[]).indexOf(q.id) >= 0)
    } else if (params !== undefined && params.tag !== undefined && params.tag !== '') {
      list = QuestionBank.filterByTag(subject, params.tag)
    } else {
      list = QuestionBank.getBySubject(subject)
    }
    const chapterNames = new Set<string>()
    list.forEach(q => chapterNames.add(q.chapter))
    this.chapters = ['全部'].concat(Array.from(chapterNames))
    this.questions = list
    this.chosen = list.map(() => -1)
    this.answered = list.map(() => false)
    this.showAnswer = list.map(() => false)
    this.ready = list.length > 0
    if (list.length === 0) {
      promptAction.showToast({ message: '该分类暂无题目' })
      setTimeout(() => router.back(), 600)
      return
    }
    this.restoreProgress()
  }

  private async restoreProgress(): Promise<void> {
    const idx = await PrefsHelper.getPracticeIndex(this.currentSubject)
    if (idx > 0 && idx < this.questions.length) {
      this.index = idx
    }
  }

  onPageShow(): void {
    PrefsHelper.incStudyDays()
  }

  aboutToDisappear(): void {
    if (this.savedOnce) {
      return
    }
    this.saveProgress()
  }

  private saveProgress(): void {
    if (this.questions.length === 0) {
      return
    }
    this.savedOnce = true
    PrefsHelper.setPracticeIndex(this.currentSubject, this.index)
  }

  private visibleQuestions(): Question[] {
    if (this.chapterFilter === '' || this.chapterFilter === '全部') {
      return this.questions
    }
    return this.questions.filter(q => q.chapter === this.chapterFilter)
  }

  private onOption(optIdx: number): void {
    if (this.answered[this.index]) {
      return
    }
    this.answered[this.index] = true
    this.chosen[this.index] = optIdx
    const q = this.questions[this.index]
    const ok = optIdx === q.answer
    DbHelper.insertAnswer(q.id, q.subject, ok ? 1 : 0)
    this.notifyList()
    if (ok) {
      promptAction.showToast({ message: '回答正确' })
    } else {
      promptAction.showToast({ message: '回答错误，已加入错题本' })
    }
  }

  /** 强制数组刷新（V1 @State 数组元素赋值需重新赋值触发） */
  private notifyList(): void {
    this.answered = this.answered.slice()
    this.chosen = this.chosen.slice()
    this.showAnswer = this.showAnswer.slice()
  }

  private go(delta: number): void {
    const list = this.visibleQuestions()
    let pos = this.index
    // 在过滤后的列表内按顺序游走；到端点则移动主列表
    pos += delta
    if (pos < 0) {
      pos = 0
    }
    if (pos >= this.questions.length) {
      pos = this.questions.length - 1
      promptAction.showToast({ message: '已是最后一题' })
    }
    this.index = pos
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('‹')
          .fontSize(26)
          .fontColor('#1F2937')
          .padding({ left: 4, right: 4 })
          .onClick(() => {
            this.saveProgress()
            router.back()
          })
        Text(this.currentSubject === 1 ? '科目一 · 顺序练习' : '科目四 · 顺序练习')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .margin({ left: 6 })
        Blank()
        Text(`${this.index + 1} / ${this.questions.length}`)
          .fontSize(14)
          .fontColor('#1C64F2')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .padding({ left: 14, right: 16, top: 10, bottom: 6 })

      // 章节筛选条
      if (this.chapters.length > 2) {
        Scroll() {
          Row() {
            ForEach(this.chapters, (name: string) => {
              ChapterChip({
                label: name === '全部' ? '全部' : name,
                active: this.chapterFilter === name || (name === '全部' && this.chapterFilter === ''),
                onTap: () => {
                  this.chapterFilter = name === '全部' ? '' : name
                  this.index = 0
                }
              })
            }, (name: string) => name)
          }
          .padding({ left: 14, right: 14, top: 4, bottom: 8 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }

      if (!this.ready) {
        Column() {
          LoadingProgress().width(40).height(40).color('#1C64F2')
          Text('题库加载中…')
            .fontSize(13)
            .fontColor('#6B7280')
            .margin({ top: 10 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            if (this.index < this.questions.length) {
              QuestionCard({
                question: this.questions[this.index],
                index: this.index + 1,
                total: this.questions.length,
                chosen: this.chosen[this.index],
                showResult: this.answered[this.index],
                showAnswer: this.showAnswer[this.index],
                onSelect: (i: number) => this.onOption(i)
              })

              if (this.answered[this.index]) {
                Row() {
                  Button('查看解析')
                    .fontSize(13)
                    .fontColor('#1C64F2')
                    .backgroundColor('#E8F0FE')
                    .height(36)
                    .padding({ left: 14, right: 14 })
                    .onClick(() => {
                      this.showAnswer[this.index] = true
                      this.notifyList()
                    })
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .margin({ top: 12 })
              }
            }
          }
          .padding({ left: 16, right: 16, top: 4, bottom: 20 })
          .constraintSize({ minWidth: '100%' })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      // 底部切换
      if (this.ready) {
        Row() {
          Button('上一题')
            .fontSize(15)
            .height(42)
            .layoutWeight(1)
            .fontColor('#1F2937')
            .backgroundColor('#F3F4F6')
            .borderRadius(21)
            .enabled(this.index > 0)
            .onClick(() => this.go(-1))
          Button(this.answered[this.index] ? '下一题' : '跳过')
            .fontSize(15)
            .height(42)
            .layoutWeight(1)
            .fontColor('#FFFFFF')
            .backgroundColor('#1C64F2')
            .borderRadius(21)
            .margin({ left: 12 })
            .onClick(() => {
              this.showAnswer[this.index] = this.answered[this.index]
              this.go(1)
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 12 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
