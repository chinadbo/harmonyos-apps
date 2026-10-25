/**
 * 学习统计：正确率趋势、章节掌握度
 */
import { AnswerRecord } from '../store/DbHelper'
import { Question } from './Question'
import { QuestionBank } from './QuestionBank'

export interface ChapterMastery {
  name: string
  answered: number
  correct: number
  rate: number // 0-100
}

export interface DailyRate {
  date: string // MM-dd
  rate: number // 0-100
  count: number
}

export class StatsHelper {
  /** 各章节掌握度：答题数/正确数/正确率 */
  static mastery(records: AnswerRecord[]): ChapterMastery[] {
    const bank = new Map<number, Question>()
    QuestionBank.all().forEach(q => bank.set(q.id, q))
    const map = new Map<string, ChapterMastery>()
    for (const r of records) {
      const q = bank.get(r.qid)
      if (!q) {
        continue
      }
      let m = map.get(q.chapter)
      if (!m) {
        m = { name: q.chapter, answered: 0, correct: 0, rate: 0 }
        map.set(q.chapter, m)
      }
      m.answered++
      if (r.correct === 1) {
        m.correct++
      }
    }
    const list: ChapterMastery[] = []
    map.forEach(m => {
      m.rate = m.answered > 0 ? Math.round(m.correct * 100 / m.answered) : 0
      list.push(m)
    })
    return list.sort((a, b) => a.rate - b.rate)
  }

  /** 最近 7 天正确率（无记录的天记 0 并跳过绘制） */
  static recentRates(records: AnswerRecord[], days: number = 7): DailyRate[] {
    const dayBuckets: Map<string, { correct: number, total: number }> = new Map()
    const keys: string[] = []
    const now = new Date()
    for (let i = days - 1; i >= 0; i--) {
      const d = new Date(now.getTime() - i * 86400000)
      const key = StatsHelper.dateKey(d)
      keys.push(key)
      dayBuckets.set(key, { correct: 0, total: 0 })
    }
    for (const r of records) {
      const bucket = dayBuckets.get(StatsHelper.dateKey(new Date(r.answeredAt)))
      if (bucket) {
        bucket.total++
        if (r.correct === 1) {
          bucket.correct++
        }
      }
    }
    return keys.map(k => {
      const b = dayBuckets.get(k)
      return {
        date: k.slice(5).replace('-', '/'),
        rate: b && b.total > 0 ? Math.round(b.correct * 100 / b.total) : -1,
        count: b ? b.total : 0
      }
    })
  }

  static dateKey(d: Date): string {
    const m = (d.getMonth() + 1).toString().padStart(2, '0')
    const day = d.getDate().toString().padStart(2, '0')
    return `${d.getFullYear()}-${m}-${day}`
  }

  static overallRate(records: AnswerRecord[]): number {
    if (records.length === 0) {
      return 0
    }
    const c = records.filter(r => r.correct === 1).length
    return Math.round(c * 100 / records.length)
  }

  /** 各章节覆盖率：已答题数 / 题库该章节总数 */
  static coverage(records: AnswerRecord[], subject: number): Map<string, number> {
    const answered = new Set(records.map(r => r.qid))
    const result = new Map<string, number>()
    const chapters = QuestionBank.chapters(subject)
    for (const c of chapters) {
      const total = QuestionBank.filterByChapter(subject, c.name).length
      const done = QuestionBank.filterByChapter(subject, c.name).filter(q => answered.has(q.id)).length
      result.set(c.name, total > 0 ? Math.round(done * 100 / total) : 0)
    }
    return result
  }
}

/** 题库静态掌握度占位（未答题时 rate=0） */
export interface BankMastery {
  name: string
  count: number
}
