/**
 * 模拟考试引擎：组卷、限时、交卷评分
 */
import { Question, EXAM_SIZE, EXAM_SECONDS, PASS_SCORE } from './Question'
import { QuestionBank } from './QuestionBank'
import { DbHelper } from '../store/DbHelper'

export interface ExamAnswer {
  qid: number
  chosen: number // -1=未答
}

export interface ExamReport {
  score: number
  total: number
  correct: number
  wrong: number
  blank: number
  passed: boolean
  weakChapters: string[]
  wrongQids: number[]
}

export class ExamEngine {
  paper: Question[] = []
  answers: ExamAnswer[] = []
  startTime: number = 0
  remainSeconds: number = EXAM_SECONDS
  submitted: boolean = false

  start(subject: number): void {
    this.paper = QuestionBank.buildExamPaper(subject, EXAM_SIZE)
    this.answers = this.paper.map(q => ({ qid: q.id, chosen: -1 }))
    this.startTime = Date.now()
    this.remainSeconds = EXAM_SECONDS
    this.submitted = false
  }

  answer(index: number, chosen: number): void {
    if (index < 0 || index >= this.answers.length) {
      return
    }
    this.answers[index].chosen = chosen
  }

  answeredCount(): number {
    return this.answers.filter(a => a.chosen >= 0).length
  }

  formatRemain(): string {
    const m = Math.floor(this.remainSeconds / 60)
    const s = this.remainSeconds % 60
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
  }

  async submit(): Promise<ExamReport> {
    this.submitted = true
    let correct = 0
    const wrongQids: number[] = []
    const chapterWrong = new Map<string, number>()
    for (let i = 0; i < this.paper.length; i++) {
      const q = this.paper[i]
      const chosen = this.answers[i].chosen
      const ok = chosen === q.answer
      if (ok) {
        correct++
      } else {
        wrongQids.push(q.id)
        chapterWrong.set(q.chapter, (chapterWrong.get(q.chapter) ?? 0) + 1)
      }
      await DbHelper.insertAnswer(q.id, q.subject, ok ? 1 : 0)
    }
    const score = Math.round(correct * 100 / this.paper.length)
    const weakChapters: string[] = []
    chapterWrong.forEach((cnt, name) => {
      if (cnt >= 3) {
        weakChapters.push(`${name}（错${cnt}题）`)
      }
    })
    return {
      score: score,
      total: this.paper.length,
      correct: correct,
      wrong: wrongQids.length,
      blank: this.answers.filter(a => a.chosen < 0).length,
      passed: score >= PASS_SCORE,
      weakChapters: weakChapters.slice(0, 3),
      wrongQids: wrongQids
    }
  }
}
