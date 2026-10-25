/**
 * 题目数据模型：题库 JSON、答题记录、错题条目的统一模型定义
 */
export interface Question {
  id: number
  subject: number // 1=科目一 4=科目四
  chapter: string
  tag: string // fine|deduction|sign|accident|general
  type: string // judge | single
  stem: string
  options: string[]
  answer: number
  explanation: string
}

/** 章节信息 */
export interface ChapterInfo {
  name: string
  count: number
}

/** 专项分类 */
export interface SpecialTag {
  key: string
  label: string
  icon: string
}

export const TAGS: SpecialTag[] = [
  { key: 'fine', label: '罚款处罚', icon: '💰' },
  { key: 'deduction', label: '记分规则', icon: '📝' },
  { key: 'sign', label: '信号标志', icon: '🚦' },
  { key: 'accident', label: '事故处理', icon: '🚨' },
  { key: 'general', label: '综合常识', icon: '📘' }
]

export const PASS_SCORE = 90
export const EXAM_SIZE = 100
export const EXAM_SECONDS = 45 * 60

export function optionLabel(index: number): string {
  return String.fromCharCode(65 + index)
}
