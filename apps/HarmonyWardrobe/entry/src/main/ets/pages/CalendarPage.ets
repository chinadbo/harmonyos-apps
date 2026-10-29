import router from '@ohos.router'
import { Clothing, Outfit, OutfitLog, OutfitView, todayDateString, toDateString, daysInMonth } from '../model/WardrobeModels'
import { WardrobeDb } from '../data/WardrobeDb'
import { showToast } from '../common/UiUtils'
import { CalendarGrid } from '../components/CalendarGrid'
import { OutfitCard } from '../components/OutfitCard'

@Entry
@Component
struct CalendarPage {
  @State year: number = new Date().getFullYear()
  @State month: number = new Date().getMonth() + 1
  @State selectedDate: string = todayDateString()
  @State monthLogs: OutfitLog[] = []
  @State allOutfits: OutfitView[] = []
  private allClothing: Clothing[] = []
  private wearCounts: Map<number, number> = new Map()
  private activeNav: number = 2

  aboutToAppear(): void {
    this.loadAll()
  }

  onPageShow(): void {
    this.loadAll()
  }

  private async loadAll(): Promise<void> {
    const db = WardrobeDb.getInstance()
    this.allClothing = await db.queryClothing('')
    this.wearCounts = await db.queryWearCounts()
    const outfits = await db.queryOutfits()
    const views: OutfitView[] = []
    outfits.forEach((o: Outfit) => {
      views.push(this.buildView(o))
    })
    this.allOutfits = views
    await this.loadMonthLogs()
  }

  private async loadMonthLogs(): Promise<void> {
    const db = WardrobeDb.getInstance()
    const start = toDateString(this.year, this.month, 1)
    const end = toDateString(this.year, this.month, daysInMonth(this.year, this.month))
    this.monthLogs = await db.queryLogsBetween(start, end)
  }

  private findById(id: number): Clothing | null {
    if (id < 0) {
      return null
    }
    for (let i = 0; i < this.allClothing.length; i++) {
      if (this.allClothing[i].id === id) {
        return this.allClothing[i]
      }
    }
    return null
  }

  private buildView(o: Outfit): OutfitView {
    const view = new OutfitView()
    view.outfit = o
    const ids: number[] = [o.topId, o.bottomId, o.outerId, o.shoesId, o.accessoryId]
    ids.forEach((id: number) => {
      const found = this.findById(id)
      if (found !== null) {
        view.items.push(found)
      }
    })
    const cnt = this.wearCounts.get(o.id)
    view.wearCount = cnt !== undefined ? cnt : 0
    return view
  }

  private logForSelected(): OutfitLog | null {
    for (let i = 0; i < this.monthLogs.length; i++) {
      if (this.monthLogs[i].logDate === this.selectedDate) {
        return this.monthLogs[i]
      }
    }
    return null
  }

  private viewFor(outfitId: number): OutfitView | null {
    for (let i = 0; i < this.allOutfits.length; i++) {
      if (this.allOutfits[i].outfit.id === outfitId) {
        return this.allOutfits[i]
      }
    }
    return null
  }

  private selectedView(): OutfitView {
    const log = this.logForSelected()
    if (log === null) {
      return new OutfitView()
    }
    const view = this.viewFor(log.outfitId)
    if (view === null) {
      return new OutfitView()
    }
    return view
  }

  private changeMonth(delta: number): void {
    let m = this.month + delta
    let y = this.year
    if (m < 1) {
      m = 12
      y = y - 1
    } else if (m > 12) {
      m = 1
      y = y + 1
    }
    this.year = y
    this.month = m
    this.loadMonthLogs()
  }

  private async record(outfitId: number): Promise<void> {
    await WardrobeDb.getInstance().insertLog(outfitId, this.selectedDate)
    showToast(`已记录到 ${this.selectedDate}`)
    await this.loadAll()
  }

  private async removeRecord(): Promise<void> {
    await WardrobeDb.getInstance().deleteLogByDate(this.selectedDate)
    showToast('已删除当天记录')
    await this.loadAll()
  }

  @Builder
  NavButton(label: string, url: string, index: number) {
    Text(label)
      .fontSize(15)
      .fontWeight(index === this.activeNav ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(index === this.activeNav ? '#3E5C76' : '#9AA7B4')
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .padding({ top: 12, bottom: 12 })
      .onClick(() => {
        if (index !== this.activeNav) {
          router.replaceUrl({ url: url })
        }
      })
  }

  @Builder
  NavBar() {
    Row() {
      this.NavButton('衣柜', 'pages/Index', 0)
      this.NavButton('搭配', 'pages/OutfitBuilder', 1)
      this.NavButton('日历', 'pages/CalendarPage', 2)
      this.NavButton('统计', 'pages/StatsPage', 3)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .border({ width: { top: 1 }, color: '#E8ECF0' })
  }

  build() {
    Column() {
      Row() {
        Text('穿搭日历')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2B3A4A')
          .layoutWeight(1)
        Text('‹')
          .fontSize(26)
          .fontColor('#3E5C76')
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.changeMonth(-1)
          })
        Text(`${this.year} 年 ${this.month} 月`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2B3A4A')
        Text('›')
          .fontSize(26)
          .fontColor('#3E5C76')
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.changeMonth(1)
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 4 })

      CalendarGrid({
        year: this.year,
        month: this.month,
        selectedDate: this.selectedDate,
        logs: this.monthLogs,
        onDayClick: (date: string) => {
          this.selectedDate = date
        }
      })
        .padding({ left: 8, right: 8 })
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ left: 16, right: 16 })

      Scroll() {
        Column() {
          if (this.logForSelected() !== null) {
            Text(`${this.selectedDate} 的穿搭`)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2B3A4A')
              .width('100%')
              .margin({ bottom: 8 })
            OutfitCard({
              data: this.selectedView(),
              onCardClick: (outfitId: number) => {
                router.pushUrl({ url: 'pages/OutfitDetail', params: { id: outfitId.toString() } })
              }
            })
            Text('删除当天记录')
              .fontSize(13)
              .fontColor('#C62828')
              .padding(8)
              .margin({ top: 8 })
              .onClick(() => {
                this.removeRecord()
              })
          } else {
            if (this.allOutfits.length > 0) {
              Text(`${this.selectedDate} 还没有记录，选择一套搭配记录到这一天：`)
                .fontSize(14)
                .fontColor('#6B7684')
                .width('100%')
                .margin({ bottom: 8 })
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.allOutfits, (view: OutfitView) => {
                  Text(view.outfit.name)
                    .fontSize(13)
                    .fontColor('#2B3A4A')
                    .backgroundColor('#F0F2F5')
                    .borderRadius(16)
                    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                    .margin(4)
                    .onClick(() => {
                      this.record(view.outfit.id)
                    })
                }, (view: OutfitView) => `${view.outfit.id}_${view.wearCount}`)
              }
              .width('100%')
            } else {
              Text('还没有搭配，先去「搭配」页创建一套吧')
                .fontSize(13)
                .fontColor('#B0B9C4')
                .margin({ top: 12 })
            }
          }
        }
        .padding(16)
      }
      .layoutWeight(1)

      this.NavBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F8')
  }
}
