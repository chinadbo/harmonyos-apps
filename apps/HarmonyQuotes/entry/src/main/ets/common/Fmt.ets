/**
 * 数字格式化工具
 */

export class Fmt {
  static pct(v: number): string {
    return (v > 0 ? '+' : '') + v.toFixed(2) + '%'
  }

  static pnl(v: number): string {
    return (v > 0 ? '+' : '') + v.toFixed(2)
  }

  static money(v: number): string {
    return v.toFixed(2)
  }

  static vol(v: number): string {
    if (v >= 100000000) {
      return (v / 100000000).toFixed(2) + '亿'
    }
    if (v >= 10000) {
      return (v / 10000).toFixed(2) + '万'
    }
    return Math.round(v).toString()
  }

  static today(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    return `${d.getFullYear()}-${m < 10 ? '0' + m : m}-${day < 10 ? '0' + day : day}`
  }

  static time(ts: number): string {
    const d = new Date(ts)
    const h = d.getHours()
    const m = d.getMinutes()
    const s = d.getSeconds()
    return `${h < 10 ? '0' + h : h}:${m < 10 ? '0' + m : m}:${s < 10 ? '0' + s : s}`
  }

  static rgba(hex: string, alpha: number): string {
    const r = parseInt(hex.substring(1, 3), 16)
    const g = parseInt(hex.substring(3, 5), 16)
    const b = parseInt(hex.substring(5, 7), 16)
    return `rgba(${r},${g},${b},${alpha})`
  }
}
