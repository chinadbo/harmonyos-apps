import { FavoriteStore } from '../service/FavoriteStore'
import { PhotoItem } from '../model/PhotoItem'

@Component
export struct FavoritesView {
  @State private favoriteUris: string[] = []
  @State private isLoading: boolean = true

  aboutToAppear(): void {
    this.loadFavorites()
  }

  private async loadFavorites(): Promise<void> {
    let context = getContext(this) as Context
    await FavoriteStore.init(context)
    this.favoriteUris = await FavoriteStore.getFavorites()
    this.isLoading = false
  }

  private async removeFavorite(uri: string): Promise<void> {
    await FavoriteStore.removeFavorite(uri)
    this.favoriteUris = this.favoriteUris.filter((u: string) => u !== uri)
  }

  build() {
    Column() {
      Row() {
        Text('收藏')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        Blank()
        Text(`${this.favoriteUris.length} 张`)
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#2196F3')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.favoriteUris.length === 0) {
        Column() {
          Text('🤍')
            .fontSize(48)
          Text('暂无收藏')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 12 })
          Text('在相册中长按图片可收藏')
            .fontSize(12)
            .fontColor('#BBBBBB')
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Grid() {
          ForEach(this.favoriteUris, (uri: string) => {
            GridItem() {
              Stack({ alignContent: Alignment.TopEnd }) {
                Image(uri)
                  .width('100%')
                  .aspectRatio(1)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)

                // 取消收藏按钮
                Button('×')
                  .width(24)
                  .height(24)
                  .borderRadius(12)
                  .backgroundColor('#CC333333')
                  .fontColor(Color.White)
                  .fontSize(16)
                  .margin({ top: 4, right: 4 })
                  .onClick(() => {
                    this.removeFavorite(uri)
                  })
              }
            }
          }, (uri: string) => uri)
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(4)
        .rowsGap(4)
        .padding({ left: 8, right: 8 })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
