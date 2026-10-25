/**
 * 题库加载：rawfile JSON 解析 + 章节索引
 */
import common from '@ohos.app.ability.common'
import util from '@ohos.util'
import { Question, ChapterInfo } from './Question'

export class QuestionBank {
  private static subject1: Question[] = []
  private static subject4: Question[] = []
  private static loaded = false

  static async load(context: common.UIAbilityContext): Promise<void> {
    if (QuestionBank.loaded) {
      return
    }
    QuestionBank.subject1 = await QuestionBank.parseBank(context, 'bank_subject1.json')
    QuestionBank.subject4 = await QuestionBank.parseBank(context, 'bank_subject4.json')
    QuestionBank.loaded = true
  }

  private static async parseBank(context: common.UIAbilityContext, file: string): Promise<Question[]> {
    const raw = await context.resourceManager.getRawFileContent(file)
    let text = ''
    let decoder = util.TextDecoder.create('utf-8')
    text = decoder.decodeWithStream(raw)
    const arr: Question[] = JSON.parse(text) as Question[]
    return arr
  }

  static getBySubject(subject: number): Question[] {
    return subject === 1 ? QuestionBank.subject1 : QuestionBank.subject4
  }

  static all(): Question[] {
    return QuestionBank.subject1.concat(QuestionBank.subject4)
  }

  static getQuestion(qid: number): Question | undefined {
    return QuestionBank.all().find(q => q.id === qid)
  }

  static chapters(subject: number): ChapterInfo[] {
    const list = QuestionBank.getBySubject(subject)
    const map = new Map<string, number>()
    for (const q of list) {
      map.set(q.chapter, (map.get(q.chapter) ?? 0) + 1)
    }
    const infos: ChapterInfo[] = []
    map.forEach((count, name) => {
      infos.push({ name: name, count: count })
    })
    return infos
  }

  static filterByTag(subject: number, tag: string): Question[] {
    return QuestionBank.getBySubject(subject).filter(q => q.tag === tag)
  }

  static filterByChapter(subject: number, chapter: string): Question[] {
    return QuestionBank.getBySubject(subject).filter(q => q.chapter === chapter)
  }

  /** 生成模拟考试卷：按比例抽取，保证章节覆盖，卷首打乱 */
  static buildExamPaper(subject: number, size: number): Question[] {
    const pool = QuestionBank.getBySubject(subject).slice()
    const paper: Question[] = []
    const step = Math.max(1, Math.floor(pool.length / size))
    for (let i = 0; i < pool.length && paper.length < size; i += step) {
      paper.push(pool[i])
    }
    // 不足时从尾部补齐
    for (let i = pool.length - 1; paper.length < size && i >= 0; i--) {
      if (paper.indexOf(pool[i]) < 0) {
        paper.push(pool[i])
      }
    }
    return QuestionBank.shuffle(paper)
  }

  /** 每日一题：按日期种子取题，同一天题目固定 */
  static dailyQuestion(): Question {
    const all = QuestionBank.all()
    if (all.length === 0) {
      return {
        id: 0, subject: 1, chapter: '', tag: 'general', type: 'judge',
        stem: '题库加载中', options: ['对', '错'], answer: 0, explanation: ''
      }
    }
    const now = new Date()
    const seed = now.getFullYear() * 372 + (now.getMonth() + 1) * 31 + now.getDate()
    return all[seed % all.length]
  }

  static shuffle<T>(arr: T[]): T[] {
    const a = arr.slice()
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      const tmp = a[i]
      a[i] = a[j]
      a[j] = tmp
    }
    return a
  }
}
