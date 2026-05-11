export enum DiaryMood {
  Happy = 'happy',
  Calm = 'calm',
  Sad = 'sad',
  Angry = 'angry',
  Excited = 'excited',
  Anxious = 'anxious',
  Grateful = 'grateful'
}

export interface EncryptedText {
  iv: string
  cipherText: string
}

export interface DiaryDraft {
  id?: number
  title: string
  content: string
  mood: DiaryMood
  date: string
  imagePaths: string[]
}

export interface DiaryRecord {
  id: number
  title: string
  content: string
  mood: DiaryMood
  date: string
  createdAt: number
  updatedAt: number
  imagePaths: string[]
}

export interface DiaryListItem {
  id: number
  title: string
  excerpt: string
  mood: DiaryMood
  date: string
  updatedAt: number
  imagePaths: string[]
}

export interface DiarySearchResult {
  id: number
  title: string
  snippet: string
  mood: DiaryMood
  date: string
}

export interface MoodOption {
  mood: DiaryMood
  label: string
  shortLabel: string
  icon: string
  color: string
  textColor: string
}

export interface MoodStat {
  mood: DiaryMood
  count: number
  percentage: number
  label: string
  color: string
}

export interface DiaryStatsSummary {
  totalCount: number
  monthlyCount: number
  streak: number
  moods: MoodStat[]
}

export interface CalendarDay {
  key: string
  label: number
  inCurrentMonth: boolean
  isToday: boolean
  hasEntry: boolean
  mood?: DiaryMood
}

export function createEmptyDraft(date: string): DiaryDraft {
  return {
    title: '',
    content: '',
    mood: DiaryMood.Calm,
    date,
    imagePaths: []
  };
}
