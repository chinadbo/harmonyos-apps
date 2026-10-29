import router from '@ohos.router'
import { Clothing, Outfit, OutfitView, WardrobeCategory, categoryEmoji, toFileUri } from '../model/WardrobeModels'
import { WardrobeDb } from '../data/WardrobeDb'
import { showToast } from '../common/UiUtils'
import { OutfitCard } from '../components/OutfitCard'

@Entry
@Component
struct OutfitBuilder {
  @State allClothing: Clothing[] = []
  @State outfitName: string = ''
  @State outfitViews: OutfitView[] = []
  @State topId: number = -1
  @State bottomId: number = -1
  @State outerId: number = -1
  @State shoesId: number = -1
  @State accessoryId: number = -1
  private wearCounts: Map<number, number> = new Map()
  private activeNav: number = 1

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
    this.outfitViews = views
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

  private clothingOf(category: string): Clothing[] {
    return this.allClothing.filter((c: Clothing) => c.category === category)
  }

  private slotId(slotKey: string): number {
    if (slotKey === 'top') {
      return this.topId
    } else if (slotKey === 'bottom') {
      return this.bottomId
    } else if (slotKey === 'outer') {
      return this.outerId
    } else if (slotKey === 'shoes') {
      return this.shoesId
    } else {
      return this.accessoryId
    }
  }

  private pickSlot(slotKey: string, id: number): void {
    if (slotKey === 'top') {
      this.topId = this.topId === id ? -1 : id
    } else if (slotKey === 'bottom') {
      this.bottomId = this.bottomId === id ? -1 : id
    } else if (slotKey === 'outer') {
      this.outerId = this.outerId === id ? -1 : id
    } else if (slotKey === 'shoes') {
      this.shoesId = this.shoesId === id ? -1 : id
    } else {
      this.accessoryId = this.accessoryId === id ? -1 : id
    }
  }

  private async save(): Promise<void> {
    if (this.topId < 0 && this.bottomId < 0 && this.outerId < 0 && this.shoesId < 0) {
      showToast('至少选择一件衣物')
      return
    }
    const name = this.outfitName === '' ? `搭配 ${this.outfitViews.length + 1}` : this.outfitName
    const outfit = new Outfit(-1, name, this.topId, this.bottomId, this.outerId,
      this.shoesId, this.accessoryId, Date.now())
    await WardrobeDb.getInstance().insertOutfit(outfit)
    showToast('搭配已保存')
    this.outfitName = ''
    this.topId = -1
    this.bottomId = -1
    this.outerId = -1
    this.shoesId = -1
    this.accessoryId = -1
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

  @Builder
  SlotSection(label: string, slotKey: string) {
    Column() {
      Row() {
        Text(label)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2B3A4A')
        if (this.slotId(slotKey) >= 0) {
          Text('已选 ✓')
            .fontSize(12)
            .fontColor('#2E7D32')
            .margin({ left: 8 })
        }
      }
      .width('100%')
      .margin({ bottom: 8 })

      Scroll({ horizontal: true, scrollBar: BarState.Off }) {
        Row({ space: 8 }) {
          ForEach(this.clothingOf(label), (item: Clothing) => {
            Column() {
              if (item.imagePath !== '') {
                Image(toFileUri(item.imagePath))
                  .width(56)
                  .height(56)
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)
              } else {
                Text(categoryEmoji(item.category))
                  .width(56)
                  .height(56)
                  .fontSize(28)
                  .textAlign(TextAlign.Center)
                  .backgroundColor('#F0F2F5')
                  .borderRadius(8)
              }
              Text(item.name)
                .fontSize(11)
                .fontColor('#6B7684')
                .maxLines(1)
            }
            .alignItems(HorizontalAlign.Center)
            .borderRadius(10)
            .border({ width: 2, color: this.slotId(slotKey) === item.id ? '#3E5C76' : Color.Transparent })
            .padding(6)
            .onClick(() => {
              this.pickSlot(slotKey, item.id)
            })
          }, (item: Clothing) => item.id.toString())
        }
      }
      .width('100%')

      if (this.clothingOf(label).length === 0) {
        Text('衣柜中还没有该分类的衣物')
          .fontSize(12)
          .fontColor('#B0B9C4')
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 10 })
  }

  build() {
    Column() {
      Row() {
        Text('穿搭搭配')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2B3A4A')
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Scroll() {
        Column() {
          TextInput({ text: this.outfitName, placeholder: '给这套搭配起个名字（可选）' })
            .fontSize(14)
            .backgroundColor(Color.White)
            .borderRadius(10)
            .height(44)
            .onChange((value: string) => {
              this.outfitName = value
            })

          Column() {
            this.SlotSection(WardrobeCategory.TOP, 'top')
            this.SlotSection(WardrobeCategory.BOTTOM, 'bottom')
            this.SlotSection(WardrobeCategory.OUTER, 'outer')
            this.SlotSection(WardrobeCategory.SHOES, 'shoes')
            this.SlotSection(WardrobeCategory.ACCESSORY, 'accessory')

            Button('保存这套搭配')
              .fontSize(16)
              .backgroundColor('#3E5C76')
              .borderRadius(22)
              .width('100%')
              .margin({ top: 6 })
              .onClick(() => {
                this.save()
              })
          }
          .width('100%')
          .margin({ top: 12 })

          if (this.outfitViews.length > 0) {
            Text(`我的搭配（${this.outfitViews.length}）`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2B3A4A')
              .width('100%')
              .alignSelf(TextAlign.Start)
              .margin({ top: 20, bottom: 8 })

            ForEach(this.outfitViews, (view: OutfitView) => {
              OutfitCard({
                data: view,
                onCardClick: (outfitId: number) => {
                  router.pushUrl({ url: 'pages/OutfitDetail', params: { id: outfitId.toString() } })
                }
              })
                .margin({ bottom: 10 })
            }, (view: OutfitView) => `${view.outfit.id}_${view.wearCount}_${view.items.length}`)
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
