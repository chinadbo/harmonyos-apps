export interface WordEntry {
  id: number
  word: string
  pinyin: string
  definition: string
  example: string
  synonyms: string
  antonyms: string
  groupName: string
  strokes: number
  radical: string
  isRecommended: number
}

export interface HistoryEntry extends WordEntry {
  historyId: number
  entryType: string
  queryText: string
  createdAt: string
}
