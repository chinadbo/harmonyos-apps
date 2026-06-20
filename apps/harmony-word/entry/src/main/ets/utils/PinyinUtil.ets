export class PinyinUtil {
  static normalize(pinyin: string): string {
    return (pinyin || '').trim().toLowerCase()
  }

  static getInitial(text: string): string {
    if (!text || text.length === 0) {
      return '#'
    }
    const first = text.charAt(0).toUpperCase()
    const code = first.charCodeAt(0)
    if (code >= 65 && code <= 90) {
      return first
    }
    return '#'
  }

  static getIndexerLabel(pinyin: string): string {
    const normalized = this.normalize(pinyin)
    if (!normalized) {
      return '#'
    }
    return this.getInitial(normalized)
  }
}
