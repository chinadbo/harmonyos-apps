/**
 * 底部导航栏：单页导航（router.pushUrl），非 Tabs 容器
 */

import router from '@ohos.router'
import { Theme } from '../common/Theme'

const NAV_LABELS: string[] = ['行情', '持仓', '统计', '自选', '设置']
const NAV_URLS: string[] = [
  'pages/Index',
  'pages/PositionsPage',
  'pages/StatsPage',
  'pages/AddQuotePage',
  'pages/SettingsPage'
]

@Component
export struct BottomNav {
  @Prop active: number = 0

  build() {
    Row() {
      ForEach(NAV_LABELS, (label: string, idx: number) => {
        Text(label)
          .fontSize(12)
          .fontWeight(idx === this.active ? FontWeight.Medium : FontWeight.Normal)
          .fontColor(idx === this.active ? Theme.ACCENT : Theme.TEXT2)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ top: 9, bottom: 9 })
          .onClick(() => {
            if (idx !== this.active) {
              router.pushUrl({ url: NAV_URLS[idx] })
            }
          })
      }, (label: string) => label)
    }
    .width('100%')
    .backgroundColor(Theme.CARD)
    .border({ width: { top: 0.5 }, color: Theme.GRID })
  }
}
