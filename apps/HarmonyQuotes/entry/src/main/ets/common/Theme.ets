/**
 * 涨跌色主题管理。themeMode 经 AppStorage key "themeMode" 全局同步，
 * 页面/组件用 @StorageLink('themeMode') 持有并在 build 中调用 Theme.up()/down()
 */

export enum ThemeMode {
  RED_UP = 'red_up',     // A股习惯：红涨绿跌（默认）
  GREEN_UP = 'green_up'  // 美股习惯：绿涨红跌
}

export class Theme {
  static readonly BG: string = '#F4F5F7'
  static readonly CARD: string = '#FFFFFF'
  static readonly TEXT: string = '#1F2329'
  static readonly TEXT2: string = '#8A8F99'
  static readonly TEXT3: string = '#C1C4CC'
  static readonly ACCENT: string = '#3D7BF7'
  static readonly UP_RED: string = '#E5393D'
  static readonly DOWN_GREEN: string = '#26A96A'
  static readonly FLAT: string = '#8A8F99'
  static readonly MA5: string = '#F5A623'
  static readonly MA10: string = '#5B8FF9'
  static readonly GRID: string = '#EEF0F3'

  static isGreenUp(mode: string): boolean {
    return mode === ThemeMode.GREEN_UP
  }

  static up(mode: string): string {
    return Theme.isGreenUp(mode) ? Theme.DOWN_GREEN : Theme.UP_RED
  }

  static down(mode: string): string {
    return Theme.isGreenUp(mode) ? Theme.UP_RED : Theme.DOWN_GREEN
  }

  static changeColor(mode: string, change: number): string {
    if (change > 0) {
      return Theme.up(mode)
    }
    if (change < 0) {
      return Theme.down(mode)
    }
    return Theme.FLAT
  }

  static pctColor(mode: string, pct: number): string {
    return Theme.changeColor(mode, pct)
  }
}
