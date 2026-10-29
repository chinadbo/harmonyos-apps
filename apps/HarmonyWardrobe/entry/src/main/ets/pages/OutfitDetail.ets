import router from '@ohos.router'
import { Clothing, Outfit, OutfitLog, OutfitView, todayDateString } from '../model/WardrobeModels'
import { WardrobeDb } from '../data/WardrobeDb'
import { showToast } from '../common/UiUtils'
import { OutfitCard } from '../components/OutfitCard'

@Entry
@Component
struct OutfitDetail {
  @State view: OutfitView = new OutfitView()
  @State logs: OutfitLog[] = []
  @State loaded: boolean = false
  private outfitId: number = -1

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    if (params !== undefined && params !== null && params.id !== undefined) {
      this.outfitId = Number(params.id)
      this.load()
    }
  }

  private async load(): Promise<void> {
    const db = WardrobeDb.getInstance()
    const outfit = await db.getOutfitById(this.outfitId)
    if (outfit === null) {
      showToast('搭配不存在')
      router.back()
      return
    }
    const allClothing = await db.queryClothing('')
    const wearCounts = await db.queryWearCounts()
    const view = new OutfitView()
    view.outfit = outfit
    const ids: number[] = [outfit.topId, outfit.bottomId, outfit.outerId, outfit.shoesId, outfit.accessoryId]
    ids.forEach((id: number) => {
      let found: Clothing | null = null
      for (let i = 0; i < allClothing.length; i++) {
        if (allClothing[i].id === id) {
          found = allClothing[i]
          break
        }
      }
      if (found !== null) {
        view.items.push(found)
      }
    })
    const cnt = wearCounts.get(outfit.id)
    view.wearCount = cnt !== undefined ? cnt : 0
    this.view = view
    this.logs = await db.queryLogsByOutfit(this.outfitId)
    this.loaded = true
  }

  private async wearToday(): Promise<void> {
    await WardrobeDb.getInstance().insertLog(this.outfitId, todayDateString())
    showToast('已记录今日穿着')
    await this.load()
  }

  private async removeOutfit(): Promise<void> {
    await WardrobeDb.getInstance().deleteOutfit(this.outfitId)
    showToast('搭配已删除')
    router.back()
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(28)
          .fontColor('#2B3A4A')
          .padding({ left: 12, right: 8 })
          .onClick(() => {
            router.back()
          })
        Text('搭配详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2B3A4A')
          .layoutWeight(1)
        Text('删除')
          .fontSize(14)
          .fontColor('#C62828')
          .padding({ left: 12, right: 16 })
          .onClick(() => {
            this.removeOutfit()
          })
      }
      .width('100%')
      .height(52)
      .backgroundColor(Color.White)

      if (this.loaded) {
        Scroll() {
          Column() {
            OutfitCard({
              data: this.view,
              onCardClick: (outfitId: number) => {
              }
            })
              .width('100%')

            Row() {
              Text(`创建于 ${this.formatDate(this.view.outfit.createdAt)}`)
                .fontSize(12)
                .fontColor('#8A97A5')
              Blank()
              Text(`累计穿着 ${this.view.wearCount} 次`)
                .fontSize(12)
                .fontColor('#8A97A5')
            }
            .width('100%')
            .margin({ top: 8, bottom: 8 })

            Button('记录今日穿着')
              .fontSize(16)
              .backgroundColor('#3E5C76')
              .borderRadius(22)
              .width('100%')
              .onClick(() => {
                this.wearToday()
              })

            Text('穿着记录')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2B3A4A')
              .width('100%')
              .alignSelf(TextAlign.Start)
              .margin({ top: 20, bottom: 8 })

            if (this.logs.length > 0) {
              ForEach(this.logs, (log: OutfitLog) => {
                Text(log.logDate)
                  .fontSize(14)
                  .fontColor('#6B7684')
                  .width('100%')
                  .padding({ top: 10, bottom: 10 })
                  .backgroundColor(Color.White)
                  .borderRadius(10)
                  .margin({ bottom: 8 })
              }, (log: OutfitLog) => log.id.toString())
            } else {
              Text('还没有穿着记录')
                .fontSize(13)
                .fontColor('#B0B9C4')
                .margin({ top: 8 })
            }
          }
          .padding(16)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F8')
  }

  private formatDate(ts: number): string {
    const d = new Date(ts)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? '0' + m.toString() : m.toString()
    const dd = day < 10 ? '0' + day.toString() : day.toString()
    return `${d.getFullYear()}-${mm}-${dd}`
  }
}
