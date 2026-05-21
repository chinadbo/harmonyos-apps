import { PhotoItem } from '../model/PhotoItem'

@Component
export struct PhotoCard {
  @Prop photo: PhotoItem = new PhotoItem()
  @Prop selected: boolean = false
  @Prop showCheckBox: boolean = false
  onTap: () => void = () => {}
  onLongPress: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image(this.photo.uri)
        .width('100%')
        .aspectRatio(this.photo.height > 0 && this.photo.width > 0
          ? this.photo.width / this.photo.height
          : 1)
        .objectFit(ImageFit.Cover)
        .borderRadius(6)
        .backgroundColor('#EEEEEE')

      if (this.showCheckBox) {
        Row() {
          if (this.selected) {
            Text('✓')
              .fontSize(14)
              .fontColor(Color.White)
              .width(22)
              .height(22)
              .borderRadius(11)
              .backgroundColor('#2196F3')
              .textAlign(TextAlign.Center)
          } else {
            Row()
              .width(22)
              .height(22)
              .borderRadius(11)
              .border({ width: 2, color: Color.White })
          }
        }
        .margin({ top: 6, left: 6 })
      }

      // 收藏角标
      if (this.photo.isFavorite && !this.showCheckBox) {
        Text('❤️')
          .fontSize(12)
          .position({ x: undefined, y: undefined })
          .alignSelf(ItemAlign.End)
          .margin({ bottom: 4, right: 4 })
      }

      // 选中遮罩
      if (this.selected) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#442196F3')
          .borderRadius(6)
      }
    }
    .width('100%')
    .onClick(() => {
      this.onTap()
    })
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction(() => {
          this.onLongPress()
        })
    )
  }
}
