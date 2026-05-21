import { PhotoItem } from '../model/PhotoItem'
import { FavoriteStore } from '../service/FavoriteStore'

@Component
export struct PhotoPreview {
  @Prop photos: PhotoItem[] = []
  @Prop initialIndex: number = 0
  onClose: () => void = () => {}

  @State private currentIndex: number = 0
  @State private isFavorite: boolean = false
  @State private showBar: boolean = true

  aboutToAppear(): void {
    this.currentIndex = this.initialIndex
    this.loadFavoriteStatus()
  }

  private async loadFavoriteStatus(): Promise<void> {
    if (this.photos.length === 0) return
    let context = getContext(this) as Context
    await FavoriteStore.init(context)
    this.isFavorite = await FavoriteStore.isFavorite(this.photos[this.currentIndex].uri)
  }

  private async toggleFavorite(): Promise<void> {
    if (this.photos.length === 0) return
    let uri = this.photos[this.currentIndex].uri
    if (this.isFavorite) {
      await FavoriteStore.removeFavorite(uri)
      this.isFavorite = false
    } else {
      await FavoriteStore.addFavorite(uri)
      this.isFavorite = true
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)

      // Swiper
      Swiper() {
        ForEach(this.photos, (photo: PhotoItem) => {
          Stack({ alignContent: Alignment.Center }) {
            Image(photo.uri)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Contain)
          }
          .width('100%')
          .height('100%')
          .onClick(() => {
            this.showBar = !this.showBar
          })
          .gesture(
            PanGesture({ direction: PanDirection.Down })
              .onActionEnd((event: GestureEvent) => {
                if (event.offsetY > 120) {
                  this.onClose()
                }
              })
          )
        }, (photo: PhotoItem) => photo.uri)
      }
      .index(this.currentIndex)
      .indicator(this.photos.length > 1)
      .width('100%')
      .height('100%')
      .onChange((index: number) => {
        this.currentIndex = index
        this.loadFavoriteStatus()
      })

      // 顶部返回栏
      if (this.showBar) {
        Row() {
          Button('返回')
            .backgroundColor('transparent')
            .fontColor(Color.White)
            .fontSize(16)
            .onClick(() => {
              this.onClose()
            })

          Blank()

          Text(`${this.currentIndex + 1} / ${this.photos.length}`)
            .fontColor(Color.White)
            .fontSize(14)
        }
        .width('100%')
        .padding({ left: 12, right: 16, top: 48, bottom: 12 })
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#CC000000', 0], ['#00000000', 1]]
        })
        .position({ x: 0, y: 0 })
      }

      // 底部操作栏
      if (this.showBar) {
        Row() {
          this.actionBtn(this.isFavorite ? '❤️' : '🤍', this.isFavorite ? '已收藏' : '收藏', () => {
            this.toggleFavorite()
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 36 })
        .justifyContent(FlexAlign.Center)
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [['#CC000000', 0], ['#00000000', 1]]
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  actionBtn(icon: string, label: string, action: () => void) {
    Column() {
      Text(icon)
        .fontSize(24)
      Text(label)
        .fontSize(12)
        .fontColor(Color.White)
        .margin({ top: 4 })
    }
    .padding({ left: 20, right: 20 })
    .onClick(action)
  }
}
