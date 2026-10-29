import router from '@ohos.router'
import { ChartItem, categoryValues } from '../model/WardrobeModels'
import { WardrobeDb } from '../data/WardrobeDb'
import { StatChart } from '../components/StatChart'

const PALETTE: string[] = ['#3E5C76', '#7FA1C4', '#C98A5B', '#8FB56A', '#B5838F', '#A08BC0', '#D9A44A', '#6FA8A0']

@Entry
@Component
struct StatsPage {
  @State categoryItems: ChartItem[] = []
  @State wearItems: ChartItem[] = []
  @State totalClothing: number = 0
  @State totalOutfits: number = 0
  @State totalWears: number = 0
  private activeNav: number = 3

  aboutToAppear(): void {
    this.load()
  }

  onPageShow(): void {
    this.load()
  }

  private async load(): Promise<void> {
    const db = WardrobeDb.getInstance()
    const clothing = await db.queryClothing('')
    this.totalClothing = clothing.length

    const countByCat = new Map<string, number>()
    clothing.forEach((c) => {
      const prev = countByCat.get(c.category)
      countByCat.set(c.category, (prev !== undefined ? prev : 0) + 1)
    })
    const catItems: ChartItem[] = []
    const cats: string[] = categoryValues()
    for (let i = 0; i < cats.length; i++) {
      const cnt = countByCat.get(cats[i])
      if (cnt !== undefined && cnt > 0) {
        catItems.push(new ChartItem(cats[i], cnt, PALETTE[i]))
      }
    }
    this.categoryItems = catItems

    const outfits = await db.queryOutfits()
    this.totalOutfits = outfits.length
    const wearCounts = await db.queryWearCounts()
    const wearList: ChartItem[] = []
    let total = 0
    outfits.forEach((o) => {
      const cnt = wearCounts.get(o.id)
      if (cnt !== undefined && cnt > 0) {
        wearList.push(new ChartItem(o.name, cnt, PALETTE[0]))
        total += cnt
      }
    })
    this.totalWears = total
    wearList.sort((a: ChartItem, b: ChartItem) => b.value - a.value)
    const top: ChartItem[] = []
    const limit = wearList.length < 6 ? wearList.length : 6
    for (let i = 0; i < limit; i++) {
      top.push(new ChartItem(wearList[i].label, wearList[i].value, PALETTE[i]))
    }
    this.wearItems = top
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

  @Builder
  StatCell(value: number, label: string) {
    Column() {
      Text(value.toString())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#3E5C76')
      Text(label)
        .fontSize(12)
        .fontColor('#8A97A5')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor('#2B3A4A')
      .width('100%')
      .alignSelf(TextAlign.Start)
      .margin({ top: 20, bottom: 8 })
  }

  build() {
    Column() {
      Row() {
        Text('穿搭统计')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2B3A4A')
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Row({ space: 10 }) {
        this.StatCell(this.totalClothing, '衣物')
        this.StatCell(this.totalOutfits, '搭配')
        this.StatCell(this.totalWears, '穿着记录')
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      Scroll() {
        Column() {
          this.SectionTitle('衣物分类占比')
          if (this.categoryItems.length > 0) {
            StatChart({ chartType: 'pie', items: this.categoryItems })
              .padding(12)
              .backgroundColor(Color.White)
              .borderRadius(12)
          } else {
            Text('添加衣物后可查看分类占比')
              .fontSize(13)
              .fontColor('#B0B9C4')
              .margin({ top: 8 })
          }

          this.SectionTitle('搭配穿着排行（前 6）')
          if (this.wearItems.length > 0) {
            StatChart({ chartType: 'bar', items: this.wearItems })
              .padding(12)
              .backgroundColor(Color.White)
              .borderRadius(12)
          } else {
            Text('在日历页记录穿搭后可查看穿着排行')
              .fontSize(13)
              .fontColor('#B0B9C4')
              .margin({ top: 8 })
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
