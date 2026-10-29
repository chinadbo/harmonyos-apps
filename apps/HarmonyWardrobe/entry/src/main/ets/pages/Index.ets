import router from '@ohos.router'
import { Clothing, categoryValues } from '../model/WardrobeModels'
import { ClothingDataSource } from '../common/ClothingDataSource'
import { WardrobeDb } from '../data/WardrobeDb'
import { WardrobeCard } from '../components/WardrobeCard'

@Entry
@Component
struct Index {
  @State dataSource: ClothingDataSource = new ClothingDataSource()
  @State currentCategory: string = '全部'
  @State totalCount: number = 0
  @State isEmpty: boolean = false
  private categories: string[] = ['全部'].concat(categoryValues())
  private activeNav: number = 0

  aboutToAppear(): void {
    this.loadClothing()
  }

  onPageShow(): void {
    this.loadClothing()
  }

  async loadClothing(): Promise<void> {
    const db = WardrobeDb.getInstance()
    const category = this.currentCategory === '全部' ? '' : this.currentCategory
    const list = await db.queryClothing(category)
    this.totalCount = list.length
    this.isEmpty = list.length === 0
    this.dataSource.notifyReload(list)
  }

  @Builder
  Header() {
    Row() {
      Column() {
        Text('我的衣柜')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2B3A4A')
        Text(`共 ${this.totalCount} 件衣物`)
          .fontSize(13)
          .fontColor('#8A97A5')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Button('＋ 添加衣物')
        .fontSize(14)
        .backgroundColor('#3E5C76')
        .borderRadius(18)
        .height(36)
        .onClick(() => {
          router.pushUrl({ url: 'pages/ClothingEdit' })
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 8 })
  }

  @Builder
  CategoryBar() {
    Scroll({ horizontal: true, scrollBar: BarState.Off }) {
      Row({ space: 8 }) {
        ForEach(this.categories, (cat: string) => {
          Text(cat)
            .fontSize(13)
            .fontColor(this.currentCategory === cat ? Color.White : '#6B7684')
            .backgroundColor(this.currentCategory === cat ? '#3E5C76' : '#F0F2F5')
            .borderRadius(14)
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .onClick(() => {
              this.currentCategory = cat
              this.loadClothing()
            })
        }, (cat: string) => cat)
      }
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  EmptyHint() {
    Column() {
      Text('🧺')
        .fontSize(56)
      Text('衣柜还是空的')
        .fontSize(15)
        .fontColor('#8A97A5')
        .margin({ top: 8 })
      Text('点击右上角添加第一件衣物吧')
        .fontSize(13)
        .fontColor('#B0B9C4')
        .margin({ top: 4 })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .layoutWeight(1)
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
      this.Header()
      this.CategoryBar()

      if (this.isEmpty) {
        this.EmptyHint()
      } else {
        Grid() {
          LazyForEach(this.dataSource, (item: Clothing) => {
            GridItem() {
              WardrobeCard({
                clothing: item,
                onCardClick: (id: number) => {
                  router.pushUrl({ url: 'pages/ClothingEdit', params: { id: id.toString() } })
                }
              })
            }
          }, (item: Clothing) => item.id.toString() + '_' + item.name)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .padding(16)
        .layoutWeight(1)
        .height('100%')
      }

      this.NavBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F8')
  }
}
